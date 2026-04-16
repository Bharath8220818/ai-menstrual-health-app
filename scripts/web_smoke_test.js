const fs = require("fs");
const path = require("path");
const { spawn, execSync } = require("child_process");
const { chromium } = require("playwright-core");

const ROOT = process.cwd();
const ARTIFACTS_DIR = path.join(ROOT, "artifacts", "web-smoke");
const RESULT_PATH = path.join(ARTIFACTS_DIR, "result.json");

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForBackendHealth(timeoutMs = 30000) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    try {
      const res = await fetch("http://127.0.0.1:8000/health");
      if (res.ok) {
        return true;
      }
    } catch (_) {}
    await sleep(1000);
  }
  return false;
}

async function startFlutterWebServer() {
  return new Promise((resolve, reject) => {
    const args = [
      "run",
      "-d",
      "web-server",
      "--web-hostname",
      "127.0.0.1",
      "--web-port",
      "8090",
      "--dart-define=API_BASE_URL=http://127.0.0.1:8000",
    ];

    const proc = spawn("flutter", args, {
      cwd: ROOT,
      shell: true,
      env: { ...process.env, CI: "true", FLUTTER_SUPPRESS_ANALYTICS: "true" },
      stdio: ["pipe", "pipe", "pipe"],
    });

    let settled = false;
    let stdoutBuffer = "";
    let stderrBuffer = "";

    const timeout = setTimeout(() => {
      if (!settled) {
        settled = true;
        reject(
          new Error(
            "Timed out waiting for flutter web server startup.\n" +
              stdoutBuffer.slice(-3000) +
              "\n" +
              stderrBuffer.slice(-3000)
          )
        );
      }
    }, 300000);

    proc.stdout.on("data", (chunk) => {
      const text = chunk.toString();
      stdoutBuffer += text;
      if (!settled && text.includes("is being served at")) {
        settled = true;
        clearTimeout(timeout);
        resolve({ proc, stdoutBuffer, stderrBuffer });
      }
    });

    proc.stderr.on("data", (chunk) => {
      stderrBuffer += chunk.toString();
    });

    proc.on("exit", (code) => {
      if (!settled) {
        settled = true;
        clearTimeout(timeout);
        reject(
          new Error(
            `flutter run exited early with code ${code}\n` +
              stdoutBuffer.slice(-3000) +
              "\n" +
              stderrBuffer.slice(-3000)
          )
        );
      }
    });
  });
}

function chromePath() {
  const candidates = [
    process.env.CHROME_PATH,
    "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
    "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
    "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe",
    "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
  ].filter(Boolean);

  for (const p of candidates) {
    if (fs.existsSync(p)) return p;
  }
  throw new Error("No Chrome/Edge executable found for Playwright.");
}

async function run() {
  ensureDir(ARTIFACTS_DIR);

  const result = {
    timestamp: new Date().toISOString(),
    backendHealth: false,
    steps: [],
    screenshots: [],
    overallPass: false,
  };

  let flutterProc = null;
  let browser = null;

  const recordStep = (name, pass, details = "") => {
    result.steps.push({ name, pass, details });
  };

  const shot = async (page, name) => {
    const file = path.join(ARTIFACTS_DIR, `${name}.png`);
    await page.screenshot({ path: file, fullPage: true });
    result.screenshots.push(file);
  };

  try {
    result.backendHealth = await waitForBackendHealth();
    if (!result.backendHealth) {
      throw new Error("Backend /health is not available on http://127.0.0.1:8000");
    }
    recordStep("Backend health", true, "GET /health responded OK");

    const flutter = await startFlutterWebServer();
    flutterProc = flutter.proc;
    recordStep("Flutter web-server startup", true, "App served at http://127.0.0.1:8090");

    browser = await chromium.launch({
      headless: true,
      executablePath: chromePath(),
      args: ["--disable-gpu", "--no-sandbox"],
    });
    const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
    const page = await context.newPage();

    await page.goto("http://127.0.0.1:8090", {
      waitUntil: "domcontentloaded",
      timeout: 120000,
    });
    await shot(page, "00_loaded");

    await page.getByText("Welcome Back").waitFor({ timeout: 120000 });
    await shot(page, "01_login");
    recordStep("Login screen visible", true, "Reached login from splash");

    const signInCandidates = page.getByText("Sign In", { exact: true });
    const signInCount = await signInCandidates.count();
    if (signInCount < 1) throw new Error("Sign In button/text not found");
    await signInCandidates.nth(Math.max(0, signInCount - 1)).click();

    await page.getByText("Quick Actions").waitFor({ timeout: 30000 });
    await shot(page, "02_home_dashboard");
    recordStep("Login with demo data", true, "Navigated to dashboard");

    await page.getByText("Cycle", { exact: true }).click();
    await page.getByText("Cycle Tracker", { exact: true }).waitFor({ timeout: 30000 });
    await shot(page, "03_cycle_tab");
    recordStep("Cycle tab", true, "Cycle Tracker rendered");

    await page.getByText("Pregnancy", { exact: true }).click();
    await page.getByText("Pregnancy Mode").first().waitFor({ timeout: 30000 });
    await shot(page, "04_pregnancy_tab");
    recordStep("Pregnancy tab", true, "Pregnancy module rendered");

    await page.getByText("AI", { exact: true }).click();
    await page.getByText("AI Insights").first().waitFor({ timeout: 30000 });
    await shot(page, "05_ai_insights_tab");
    recordStep("AI insights tab", true, "Insights screen rendered");

    await page.getByText("AI Chat", { exact: true }).click();
    await page.getByPlaceholder("Ask about your health...").fill("Can I get pregnant today?");
    await page.getByPlaceholder("Ask about your health...").press("Enter");
    await page.getByText("Can I get pregnant today?").waitFor({ timeout: 30000 });

    const responseLocators = [
      page.getByText("I can help with cycle health"),
      page.getByText("best time to conceive"),
      page.getByText("fertile window"),
    ];

    let responseSeen = false;
    for (let i = 0; i < 60 && !responseSeen; i++) {
      for (const loc of responseLocators) {
        if ((await loc.count()) > 0) {
          responseSeen = true;
          break;
        }
      }
      if (!responseSeen) await sleep(500);
    }

    await shot(page, "06_ai_chat_tab");
    recordStep(
      "AI chat send/receive",
      responseSeen,
      responseSeen
        ? "User message and assistant response detected"
        : "User message sent but assistant response text pattern not detected"
    );

    await page.getByText("Profile", { exact: true }).click();
    await page.getByText("App Settings", { exact: true }).waitFor({ timeout: 30000 });
    await shot(page, "07_profile_tab");
    recordStep("Profile tab", true, "Profile settings rendered");

    await page.getByText("Home", { exact: true }).click();
    await page.getByText("Quick Actions").waitFor({ timeout: 30000 });
    await shot(page, "08_home_return");
    recordStep("Home return", true, "Returned to dashboard");

    result.overallPass = result.steps.every((s) => s.pass);
  } catch (err) {
    try {
      if (browser) {
        const context = browser.contexts()[0];
        if (context) {
          const page = context.pages()[0];
          if (page) {
            await page.screenshot({
              path: path.join(ARTIFACTS_DIR, "error_state.png"),
              fullPage: true,
            });
            result.screenshots.push(path.join(ARTIFACTS_DIR, "error_state.png"));
          }
        }
      }
    } catch (_) {}
    recordStep("Unhandled test failure", false, String(err && err.stack ? err.stack : err));
    result.overallPass = false;
  } finally {
    if (browser) {
      await browser.close().catch(() => {});
    }
    if (flutterProc && flutterProc.pid) {
      try {
        execSync(`taskkill /PID ${flutterProc.pid} /T /F`, { stdio: "ignore" });
      } catch (_) {}
    }
    fs.writeFileSync(RESULT_PATH, JSON.stringify(result, null, 2), "utf8");
    process.stdout.write(`${RESULT_PATH}\n`);
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
    if (!result.overallPass) {
      process.exitCode = 1;
    }
  }
}

run();
