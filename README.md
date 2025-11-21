<h1>📦 WARC Preservation Toolkit</h1>
<p><em>A guided workflow for downloading, verifying, extracting, renaming, and analyzing Archive-It WARC files.</em></p>

<p>
This toolkit provides a simple, reliable process for working with Archive-It WARC files on a Windows computer.<br>
Each step uses a script that prompts you for information—no coding experience is required.
</p>

<hr>

<h2>🚀 What the Toolkit Does</h2>

<p>The scripts in this toolkit help you:</p>

<ul>
  <li>Download WARCs from an Archive-It collection</li>
  <li>Check the completeness of your downloaded files</li>
  <li><strong>Extract compressed <code>.warc.gz</code> files using a Python-based workflow (default)</strong></li>
  <li>Create renamed copies of WARC files using a clear, consistent pattern</li>
  <li>Identify primary seed URLs for each WARC</li>
  <li>Generate structured metadata files (TXT, JSON, CSV, XLSX)</li>
</ul>

<p>All tools run through <strong>PowerShell</strong> using simple prompts.</p>

<hr>

<h2>📁 Included Tools</h2>

<p>The toolkit folder contains:</p>

<ul>
  <li><code>1_Download-WARCs-ByCollection.ps1</code></li>
  <li><code>2_Check-WarcDownloads.ps1</code></li>
  <li><code>3_Extract-Collection-WARCs_Python.ps1</code> <strong>(new default extractor)</strong></li>
  <li><code>Legacy_Extract-Folder-Warcs.ps1</code> <em>(previous 7-Zip method)</em></li>
  <li><code>4_Rename-WARCs.ps1</code></li>
  <li><code>5_Identify-Seeds.ps1</code></li>
</ul>

<p>Python helpers:</p>
<ul>
  <li><code>convert_warc_gz.py</code></li>
  <li><code>rename_warcs_copy_agency.py</code></li>
  <li><code>warc_seed_tools.py</code></li>
</ul>

<p>Helper executables:</p>
<ul>
  <li><code>wget.exe</code></li>
  <li><code>jq.exe</code></li>
</ul>

<p>No additional tools need to be downloaded.</p>

<hr>

<h2>📥 How to Download This Toolkit</h2>

<ol>
  <li>Visit the repository:<br>
      <strong>https://github.com/edoring/WARC-Preservation-Scripts</strong>
  </li>
  <li>Click the green <strong>Code</strong> button.</li>
  <li>Select <strong>Download ZIP</strong>.</li>
  <li>Save the ZIP and choose <strong>Extract All…</strong></li>
  <li>Open the extracted folder.<br>
      This folder contains all scripts and tools.
  </li>
</ol>

<hr>

<h2>🐍 Python Installation (One-Time Setup)</h2>

<p>The toolkit uses Python internally for extracting <code>.warc.gz</code> files.</p>

<p>To install Python:</p>

<ol>
  <li>Visit: <a href="https://www.python.org/downloads/windows/">https://www.python.org/downloads/windows/</a></li>
  <li>Click <strong>Download Python 3.x.x</strong></li>
  <li>Run the installer</li>
  <li>Check the box: <strong>Add Python to PATH</strong></li>
  <li>Click <strong>Install Now</strong></li>
  <li>Restart your computer</li>
</ol>

<p>You only need to do this once.</p>

<hr>

<h2>🔧 Running the Scripts</h2>

<p>All scripts in this toolkit are run the same way:</p>

<ol>
  <li>Open <strong>File Explorer</strong></li>
  <li>Navigate to the Toolkit folder</li>
  <li>Right-click a script</li>
  <li>Select <strong>Run with PowerShell</strong></li>
  <li>Follow the prompts</li>
</ol>

<p>Each script will guide you step by step.</p>

<hr>

<h2>📚 Full Documentation</h2>

<p>The full workflow is documented in the GitHub Wiki:</p>

<p>👉 <strong><a href="https://github.com/edoring/WARC-Preservation-Scripts/wiki">https://github.com/edoring/WARC-Preservation-Scripts/wiki</a></strong></p>

<p>The workflow includes:</p>

<ol>
  <li><strong>Step 1 – Download WARC Files</strong></li>
  <li><strong>Step 2 – Verify & Repair Downloads</strong></li>
  <li><strong>Step 3 – Extract WARC Files (Python Default Method)</strong></li>
  <li><strong>Step 4 – Rename WARC Files</strong></li>
  <li><strong>Step 5 – Identify Seed URLs</strong></li>
</ol>

<p>Each page mirrors the scripts exactly so you always know what to expect.</p>

<hr>

<h2>🖥 System Requirements</h2>

<ul>
  <li>Windows 10 or Windows 11</li>
  <li>PowerShell</li>
  <li>Python 3.10+</li>
  <li>Archive-It username and password</li>
  <li>Archive-It collection ID</li>
  <li>Adequate disk space for WARCs</li>
</ul>

<hr>

<h2>✨ Credits</h2>

<p>Created and maintained by<br>
<strong>Elizabeth Doring</strong><br>
Archivist – Oklahoma Department of Libraries</p>
