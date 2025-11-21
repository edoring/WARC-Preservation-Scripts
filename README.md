<h1>📦 WARC Preservation Toolkit</h1>
<p><em>A step-by-step workflow for downloading, verifying, extracting, renaming, and analyzing Archive-It WARC files.</em></p>

<hr>

<h2>📚 Full Documentation</h2>
<p>📘 <strong>Complete step-by-step instructions:</strong><br>
➡️ <a href="https://github.com/edoring/WARC-Preservation-Scripts/wiki">https://github.com/edoring/WARC-Preservation-Scripts/wiki</a></p>

<hr>

<h2>📝 Overview</h2>
<p>This toolkit provides a straightforward, repeatable workflow for processing Archive-It WARC files in a Windows environment. It includes scripts for:</p>

<ul>
  <li>Downloading WARC files by collection</li>
  <li>Verifying WARC download completeness and repairing missing or zero-byte files</li>
  <li>Extracting <code>.warc.gz</code> files into <code>.warc</code> format</li>
  <li>Renaming WARCs using agency name + capture date</li>
  <li>Identifying seed URLs for each capture</li>
</ul>

<hr>

<h2>📥 How to Download the Full Toolkit (Important)</h2>

<p>To use this toolkit, you must download the entire folder to your computer.</p>

<h3>Follow these steps:</h3>
<ol>
  <li>Open the project page:<br>
      <a href="https://github.com/edoring/WARC-Preservation-Scripts">https://github.com/edoring/WARC-Preservation-Scripts</a>
  </li>
  <li>Click the green <strong>Code</strong> button near the top right.</li>
  <li>Select <strong>Download ZIP</strong>.</li>
  <li>Save the ZIP file to your computer.</li>
  <li>Right-click the ZIP file and choose <strong>Extract All…</strong>.</li>
  <li>Open the extracted folder.<br>
      This folder contains:
      <ul>
        <li>PowerShell scripts</li>
        <li>Python scripts</li>
        <li>Helper tools (<code>jq.exe</code>, <code>wget.exe</code>)</li>
        <li>Documentation</li>
      </ul>
  </li>
</ol>

<p>All scripts must be run from inside the extracted folder. No additional installation is required other than Python.</p>

<hr>

<h2>📥 How to Install Python (One-Time Setup)</h2>

<p>Python is required for several scripts, but you do <em>not</em> need to run Python directly.</p>

<ol>
  <li>Go to: <a href="https://www.python.org/downloads/windows/">https://www.python.org/downloads/windows/</a></li>
  <li>Click <strong>Download Python 3.x.x</strong>.</li>
  <li>Open your Downloads folder.</li>
  <li>Double-click the installer (e.g., <code>python-3.x.x-amd64.exe</code>).</li>
  <li>On the first screen:
    <ul>
      <li>Check <strong>Add Python to PATH</strong></li>
      <li>Click <strong>Install Now</strong></li>
    </ul>
  </li>
  <li>Wait for installation.</li>
  <li>Click <strong>Close</strong> when done.</li>
  <li>Restart your computer.</li>
</ol>

<hr>

<h2>🗂 Quick Links (Wiki)</h2>

<ul>
  <li><a href="https://github.com/edoring/WARC-Preservation-Scripts/wiki">Home – Overview</a></li>
  <li><a href="https://github.com/edoring/WARC-Preservation-Scripts/wiki/Step-1-Download-WARC-Files">Step 1 – Download WARC Files</a></li>
  <li><a href="https://github.com/edoring/WARC-Preservation-Scripts/wiki/Step-2-Verify-and-Repair-WARC-Downloads">Step 2 – Verify &amp; Repair WARC Downloads</a></li>
  <li><a href="https://github.com/edoring/WARC-Preservation-Scripts/wiki/Step-3-Extract-WARC-Files">Step 3 – Extract WARC Files</a></li>
  <li><a href="https://github.com/edoring/WARC-Preservation-Scripts/wiki/Step-4-Rename-WARC-Files">Step 4 – Rename WARC Files</a></li>
  <li><a href="https://github.com/edoring/WARC-Preservation-Scripts/wiki/Step-5-Identify-Seed-URLs">Step 5 – Identify Seed URLs</a></li>
</ul>

<hr>

<h2>🗃 Included Scripts</h2>

<ul>
  <li><code>1_Download-WARCs-ByCollection.ps1</code> — Download WARCs from Archive-It</li>
  <li><code>2_Check-WarcDownloads.ps1</code> — Verify completeness, detect zero-byte files, and automatically re-download missing/partial WARCs</li>
  <li><code>3_Extract-Folder-Warcs.ps1</code> — Extract <code>.warc.gz</code> files into <code>.warc</code></li>
  <li><code>4_Rename_WARCs.ps1</code> — Rename WARCs using agency name + capture date (creates metadata)</li>
  <li><code>5_Identify-Seeds.ps1</code> — Identify seed URLs and generate CSV</li>
  <li><code>rename_warcs_copy_agency.py</code> — Automatic renaming backend</li>
  <li><code>warc_seed_tools.py</code> — Automatic seed-detection backend</li>
  <li><code>wget.exe</code> — Helper tool</li>
  <li><code>jq.exe</code> — Helper tool</li>
</ul>

<hr>

<h2>🖥 System Requirements</h2>

<ul>
  <li>Windows 10 or Windows 11</li>
  <li>PowerShell</li>
  <li>Python 3.10+</li>
  <li>Archive-It login credentials</li>
  <li>Adequate local storage for large collections</li>
</ul>

<hr>

<h2>✨ Credits</h2>
<p>Created by <strong>Elizabeth Doring</strong><br>
Archivist — Oklahoma Department of Libraries</p>


