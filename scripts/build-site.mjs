import { cp, mkdir, readdir, readFile, rm, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const outputDirectory = path.join(root, "_site");
const metadataPath = path.join(root, "site", "report-metadata.json");
const repositoryUrl = "https://github.com/microsoft/VivaRMDReportMarketplace";
const validateOnly = process.argv.includes("--validate");

const escapeHtml = (value) =>
  String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");

const encodePath = (value) => value.split("/").map(encodeURIComponent).join("/");

async function exists(filePath) {
  try {
    await stat(filePath);
    return true;
  } catch {
    return false;
  }
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function topicFilePath(topicDirectory, relativePath, expectedExtension, reportSlug) {
  assert(typeof relativePath === "string" && relativePath.trim(), `${reportSlug}: path is required.`);
  assert(path.extname(relativePath).toLowerCase() === expectedExtension, `${reportSlug}: ${relativePath} must be a ${expectedExtension} file.`);
  const resolvedPath = path.resolve(topicDirectory, relativePath);
  assert(
    resolvedPath.startsWith(`${topicDirectory}${path.sep}`),
    `${reportSlug}: ${relativePath} must remain within its topic directory.`
  );
  return resolvedPath;
}

async function loadReports() {
  const reports = JSON.parse(await readFile(metadataPath, "utf8"));
  assert(Array.isArray(reports) && reports.length > 0, "Report metadata must be a non-empty array.");

  const slugs = new Set();
  for (const report of reports) {
    assert(/^[a-z0-9-]+$/.test(report.slug), `Invalid slug: ${report.slug}`);
    assert(!slugs.has(report.slug), `Duplicate report slug: ${report.slug}`);
    slugs.add(report.slug);
    for (const field of ["title", "summary", "category", "reportType", "dataScope", "complexity"]) {
      assert(typeof report[field] === "string" && report[field].trim(), `${report.slug}: missing ${field}.`);
    }
    assert(Array.isArray(report.tags) && report.tags.length > 0, `${report.slug}: add at least one tag.`);
    assert(Array.isArray(report.previews) && report.previews.length > 0, `${report.slug}: add at least one preview.`);

    const topicDirectory = path.join(root, "templates", report.slug);
    const readmePath = path.join(topicDirectory, "README.md");
    assert(await exists(readmePath) && (await stat(readmePath)).isFile(), `${report.slug}: README.md is missing.`);
    for (const preview of report.previews) {
      assert(typeof preview.title === "string" && preview.title.trim(), `${report.slug}: every preview requires a title.`);
      const previewPath = topicFilePath(topicDirectory, preview.html, ".html", report.slug);
      const sourcePath = topicFilePath(topicDirectory, preview.source, ".rmd", report.slug);
      assert(await exists(previewPath), `${report.slug}: ${preview.html} is missing.`);
      assert((await stat(previewPath)).isFile() && (await stat(previewPath)).size > 0, `${report.slug}: ${preview.html} must be a non-empty file.`);
      assert(await exists(sourcePath) && (await stat(sourcePath)).isFile(), `${report.slug}: ${preview.source} is missing.`);
    }
  }

  const templateDirectories = (await readdir(path.join(root, "templates"), { withFileTypes: true }))
    .filter((entry) => entry.isDirectory() && entry.name !== "tests")
    .map((entry) => entry.name);
  for (const directory of templateDirectories) {
    assert(slugs.has(directory), `${directory}: add an entry to site/report-metadata.json.`);
  }
  assert(templateDirectories.length === reports.length, "Every template topic must have exactly one metadata entry.");
  return reports;
}

function pageShell({ title, description, body, depth = "" }) {
  const prefix = depth ? "../".repeat(depth) : "";
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="${escapeHtml(description)}">
  <meta name="color-scheme" content="light dark">
  <title>${escapeHtml(title)} | Viva RMarkdown Report Marketplace</title>
  <link rel="stylesheet" href="${prefix}assets/site.css">
</head>
<body>
  <a class="skip-link" href="#main-content">Skip to content</a>
  <header class="site-header">
    <a class="brand" href="${prefix}index.html">Viva <span>Report Marketplace</span></a>
    <nav aria-label="Primary navigation">
      <a href="${prefix}index.html#reports">Browse reports</a>
      <a href="${repositoryUrl}#how-to-use-a-report-template">Use a report</a>
      <a href="${repositoryUrl}">GitHub</a>
    </nav>
  </header>
  <main id="main-content">${body}</main>
  <footer><p>Open-source RMarkdown templates for Viva Insights analysis.</p><a href="${repositoryUrl}">View the repository on GitHub</a></footer>
</body>
</html>`;
}

function reportCard(report) {
  const tags = report.tags.map((tag) => `<li>${escapeHtml(tag)}</li>`).join("");
  return `<article class="report-card" data-search="${escapeHtml([report.title, report.summary, report.category, report.reportType, report.dataScope, report.complexity, ...report.tags].join(" "))}" data-category="${escapeHtml(report.category)}" data-complexity="${escapeHtml(report.complexity)}">
    <div class="card-art" aria-hidden="true"><span></span><span></span><span></span></div>
    <div class="card-content">
      <p class="eyebrow">${escapeHtml(report.category)}</p>
      <h3><a href="reports/${encodeURIComponent(report.slug)}/">${escapeHtml(report.title)}</a></h3>
      <p>${escapeHtml(report.summary)}</p>
      <ul class="tag-list">${tags}</ul>
      <div class="card-footer"><span>${escapeHtml(report.reportType)}</span><span>${report.previews.length} preview${report.previews.length === 1 ? "" : "s"}</span></div>
    </div>
  </article>`;
}

function detailPage(report) {
  const previewItems = report.previews.map((preview) => {
    const previewPath = `../../previews/${encodeURIComponent(report.slug)}/${encodePath(preview.html)}`;
    const sourceUrl = `${repositoryUrl}/blob/main/templates/${encodeURIComponent(report.slug)}/${encodePath(preview.source)}`;
    return `<li><a class="preview-link" href="${previewPath}">${escapeHtml(preview.title)} <span aria-hidden="true">↗</span></a><a class="source-link" href="${sourceUrl}">View RMarkdown source</a></li>`;
  }).join("");
  const readmeUrl = `${repositoryUrl}/tree/main/templates/${encodeURIComponent(report.slug)}`;
  const body = `<section class="report-hero">
    <p class="eyebrow">${escapeHtml(report.category)} · ${escapeHtml(report.complexity)}</p>
    <h1>${escapeHtml(report.title)}</h1>
    <p class="lede">${escapeHtml(report.summary)}</p>
    <div class="metadata"><span>${escapeHtml(report.reportType)}</span><span>${escapeHtml(report.dataScope)}</span></div>
  </section>
  <section class="detail-grid">
    <div>
      <h2>Interactive previews</h2>
      <p>Each preview opens as a full report in a new tab.</p>
      <ul class="preview-list">${previewItems}</ul>
    </div>
    <aside class="notice">
      <h2>Before you adapt it</h2>
      <p>Read the template documentation and apply appropriate privacy, aggregation and disclosure controls to real organisational data.</p>
      <a href="${readmeUrl}">Read the template documentation</a>
    </aside>
  </section>`;
  return pageShell({
    title: report.title,
    description: report.summary,
    body,
    depth: 2
  });
}

async function build(reports) {
  await rm(outputDirectory, { recursive: true, force: true });
  await mkdir(path.join(outputDirectory, "assets"), { recursive: true });
  await cp(path.join(root, "site", "assets"), path.join(outputDirectory, "assets"), { recursive: true });

  for (const report of reports) {
    const destination = path.join(outputDirectory, "reports", report.slug);
    await mkdir(destination, { recursive: true });
    await writeFile(path.join(destination, "index.html"), detailPage(report));
    const previewDirectory = path.join(outputDirectory, "previews", report.slug);
    await mkdir(previewDirectory, { recursive: true });
    await cp(path.join(root, "templates", report.slug, "README.md"), path.join(previewDirectory, "README.md"));
    for (const preview of report.previews) {
      await cp(path.join(root, "templates", report.slug, preview.html), path.join(previewDirectory, preview.html));
    }
  }

  const categories = [...new Set(reports.map((report) => report.category))].sort();
  const filters = categories.map((category) => `<button type="button" data-filter="${escapeHtml(category)}">${escapeHtml(category)}</button>`).join("");
  const body = `<section class="masthead">
    <div><p class="eyebrow">Viva Insights · RMarkdown templates</p><h1>Find the right report<br><em>for the question.</em></h1><p class="lede">Browse reusable RMarkdown reports, explore working demonstrations and start from a template that fits your analysis.</p><a class="button" href="#reports">Explore ${reports.length} reports</a></div>
    <div class="hero-panel" aria-hidden="true"><span class="panel-label">REPORT LIBRARY</span><strong>${reports.length}</strong><span>templates ready to explore</span><div class="chart"><i></i><i></i><i></i><i></i><i></i></div></div>
  </section>
  <section class="browse-section" id="reports">
    <div class="section-heading"><div><p class="eyebrow">Browse the collection</p><h2>Reports for analysis,<br>learning and exploration.</h2></div><p>${reports.length} report templates · ${reports.reduce((count, report) => count + report.previews.length, 0)} interactive previews</p></div>
    <div class="controls"><label for="search">Search reports and topics</label><input id="search" type="search" placeholder="Search Copilot, networks, meetings…" autocomplete="off"><div class="filters"><button type="button" data-filter="all" aria-pressed="true">All reports</button>${filters}</div></div>
    <p id="result-count" class="result-count" aria-live="polite">${reports.length} reports</p>
    <div class="report-grid">${reports.map(reportCard).join("")}</div>
  </section>
  <section class="how-to"><p class="eyebrow">Getting started</p><h2>Make a report your own.</h2><ol><li><strong>Choose a template</strong><span>Start with a report that best matches the question and data you have.</span></li><li><strong>Read its guidance</strong><span>Check the expected inputs, packages and appropriate-use notes.</span></li><li><strong>Render locally</strong><span>Adapt the RMarkdown source and generate your own HTML report.</span></li></ol><a class="button button-secondary" href="${repositoryUrl}#how-to-use-a-report-template">How to use a report</a></section>
  <script src="assets/site.js"></script>`;
  await writeFile(path.join(outputDirectory, "index.html"), pageShell({
    title: "Browse reports",
    description: "Browse reusable Viva Insights RMarkdown report templates and interactive demonstrations.",
    body
  }));
  await writeFile(path.join(outputDirectory, ".nojekyll"), "");
}

try {
  const reports = await loadReports();
  if (validateOnly) {
    console.log(`Validated ${reports.length} report topics and ${reports.reduce((count, report) => count + report.previews.length, 0)} previews.`);
  } else {
    await build(reports);
    console.log(`Built ${reports.length} report pages in ${path.relative(root, outputDirectory)}.`);
  }
} catch (error) {
  console.error(`Site build failed: ${error.message}`);
  process.exitCode = 1;
}
