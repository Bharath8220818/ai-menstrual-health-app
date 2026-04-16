const fs = require("fs");
const path = require("path");
const { spawn, execSync } = require("child_process");
const { chromium } = require("playwright-core");

const ROOT = process.cwd();
const OUT_DIR = path.join(ROOT, "artifacts", "web-walkthrough");
const RESULT_PATH = path.join(OUT_DIR, "result.json");

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForHealth(timeoutMs = 30000) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    try {
      const r = await fetch("http://127.0.0.1:8000/health");
      if (r.ok) return true;
    } catch (_) {}
    await sleep(1000);
  }
  return false;
}

async function startFlutter() {
  return new Promise((resolve, reject) => {
    const proc = spawn(
      "flutter",
      [
        "run",
        "-d",
        "web-server",
        "--web-hostname",
        "127.0.0.1",
        "--web-port",
        "8090",
        "--dart-define=API_BASE_URL=http://127.0.0.1:8000",
      ],
      {
        cwd: ROOT,
        shell: true,
        env: { ...process.env, CI: "true", FLUTTER_SUPPRESS_ANALYTICS: "true" },
        stdio: ["pipe", "pipe", "pipe"],
      }
    );

    let out = "";
    let err = "";
    const timer = setTimeout(() => {
      reject(
        new Error(
          "Flutter start timeout\n" + out.slice(-2500) + "\n" + err.slice(-2500)
        )
      );
    }, 300000);

    proc.stdout.on("data", (d) => {
      const t = d.toString();
      out += t;
      if (t.includes("is being served at")) {
        clearTimeout(timer);
        resolve(proc);
      }
    });
    proc.stderr.on("data", (d) => {
      err += d.toString();
    });
    proc.on("exit", (code) => {
      clearTimeout(timer);
      reject(new Error(`Flutter exited early: ${code}\n${out}\n${err}`));
    });
  });
}

function getBrowserExecutable() {
  const candidates = [
    process.env.CHROME_PATH,
    "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
    "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
    "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe",
    "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
  ].filter(Boolean);
  for (const c of candidates) {
    if (fs.existsSync(c)) return c;
  }
  throw new Error("No Chrome/Edge executable found.");
}

async function run() {
  ensureDir(OUT_DIR);
  const result = {
    timestamp: new Date().toISOString(),
    backendHealth: false,
    screenshots: [],
    urls: [],
    steps: [],
    pass: false,
  };

  let browser = null;
  let flutterProc = null;

  const step = (name, pass, notes = "") => {
    result.steps.push({ name, pass, notes });
  };

  const shot = async (page, name) => {
    const p = path.join(OUT_DIR, `${name}.png`);
    await page.screenshot({ path: p, fullPage: true });
    result.screenshots.push(p);
    result.urls.push({ name, url: page.url() });
  };

  try {
    result.backendHealth = await waitForHealth();
    step("Backend health", result.backendHealth, "http://127.0.0.1:8000/health");
    if (!result.backendHealth) throw new Error("Backend not reachable on :8000");

    flutterProc = await startFlutter();
    step("Flutter web server", true, "http://127.0.0.1:8090");

    browser = await chromium.launch({
      headless: true,
      executablePath: getBrowserExecutable(),
      args: ["--disable-gpu", "--no-sandbox"],
    });
    const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
    const page = await context.newPage();

    await page.goto("http://127.0.0.1:8090", { waitUntil: "domcontentloaded", timeout: 120000 });
    await sleep(18000);
    await shot(page, "01_login_screen");
    step("Login screen capture", true);

    // Sign in button (approx center-lower on login card)
    await page.mouse.click(215, 423);
    await sleep(4000);
    let loggedInViaUi = page.url().includes("#/home");
    step("Login action via UI", loggedInViaUi, `URL after click: ${page.url()}`);

    if (!loggedInViaUi) {
      await page.goto("http://127.0.0.1:8090/#/home", {
        waitUntil: "domcontentloaded",
        timeout: 120000,
      });
      await sleep(5000);
    }
    await shot(page, "02_home_after_login");
    step(
      "Home screen available",
      page.url().includes("#/home"),
      `URL after home fallback: ${page.url()}`
    );

    // Bottom tabs coordinates for 1440px width
    await page.mouse.click(500, 870); // Cycle
    await sleep(1800);
    await shot(page, "03_cycle_tab");
    step("Cycle tab click", true);

    await page.mouse.click(720, 870); // Pregnancy
    await sleep(1800);
    await shot(page, "04_pregnancy_tab");
    step("Pregnancy tab click", true);

    await page.mouse.click(930, 870); // AI
    await sleep(3000);
    await shot(page, "05_ai_insights_tab");
    step("AI insights tab click", true);

    await page.mouse.click(930, 115); // AI Chat top tab
    await sleep(1200);
    await page.mouse.click(680, 820); // input box
    await page.keyboard.type("Can I get pregnant today?");
    await page.keyboard.press("Enter");
    await sleep(5000);
    await shot(page, "06_ai_chat_tab");
    step("AI chat send message", true);

    await page.mouse.click(1160, 870); // Profile
    await sleep(1800);
    await shot(page, "07_profile_tab");
    step("Profile tab click", true);

    await page.mouse.click(280, 870); // Home
    await sleep(1800);
    await shot(page, "08_home_return");
    step("Home return click", true);

    result.pass = result.steps.every((s) => s.pass);
  } catch (e) {
    step("Unhandled failure", false, String(e && e.stack ? e.stack : e));
    result.pass = false;
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
    if (!result.pass) process.exitCode = 1;
  }
}

run();
