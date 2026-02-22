// Prints a local HTML file to PDF using Chrome via Puppeteer.
// Usage: node scripts/print_pdf.js /abs/path/to/index.html /abs/path/to/out.pdf
const fs = require("fs");
const path = require("path");

async function main() {
  const [, , htmlPath, outPath] = process.argv;
  if (!htmlPath || !outPath) {
    console.error("Usage: node scripts/print_pdf.js <htmlPath> <outPdfPath>");
    process.exit(1);
  }

  if (!fs.existsSync(htmlPath)) {
    console.error(`HTML not found: ${htmlPath}`);
    process.exit(1);
  }

  const puppeteer = require("puppeteer-core");
  const chromePaths = [
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
  ];
  const executablePath = chromePaths.find((p) => fs.existsSync(p));
  if (!executablePath) {
    console.error("Chrome/Brave not found in /Applications.");
    process.exit(1);
  }

  const browser = await puppeteer.launch({
    executablePath,
    headless: "new",
  });
  try {
    const page = await browser.newPage();
    await page.goto(`file://${path.resolve(htmlPath)}`, { waitUntil: "networkidle0" });
    await page.pdf({
      path: outPath,
      printBackground: true,
      displayHeaderFooter: false,
      preferCSSPageSize: true,
      scale: 1.08,
      margin: {
        top: "0.25in",
        right: "0.25in",
        bottom: "0.25in",
        left: "0.2in",
      },
    });
  } finally {
    await browser.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
