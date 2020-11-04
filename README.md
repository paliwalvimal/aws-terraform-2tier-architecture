# aws-terraform-2tier-architecture
Spin up a 2-tier infrastructure on AWS Cloud using this terraform script within few minutes.

### !!! This repository is deprecated. Please visit github.com/terrablocks for up to date terraform modules !!!

<strong>Prerequisites:</strong>
<ul>
  <li>AWS Account</li>
  <li>IAM User with Access Key & Secret Key</li>
  <li>AWS CLI (<a target="_blank" href="https://aws.amazon.com/cli/">Download</a>)</li>
  <li>Terraform (<a target="_blank" href="https://www.terraform.io/downloads.html">Download</a>)</li>
</ul>

<strong>1. Configure local machine:</strong>
<ul>
  <li>Install AWS CLI</li>
  <li>Open terminal(linux/mac)/command prompt(windows)</li>
  <li>Run <code>aws configure</code></li>
  <li>Provide the access key, secret key and region as requested</li>
</ul>

<strong>2. Setup 2-tier Infrastructure:</strong>
<ul>
  <li>Unzip downloaded terraform file</li>
  <li>Add terraform executable file to your environment variable (Optional)</li>
  <li>Download all the files leaving .gitignore and README.md files. <strong>Note: You must generate your own private & public key</strong></li>
  <li>Open terminal(linux)/command prompt(windows)</li>
  <li>Run <code>terraform init</code> command</li>
  <li>Run <code>terraform apply</code> command. Provide <strong>yes</strong> as input when asked and hit enter</li>
</ul>

<h2><strong>Hurray!! Your infrastructure is now ready.</strong></h2>

<p>3. Let's Test the Infrastructure:</p>
<ul>
  <li>Go to EC2 dashboard and click on Load Balancer in the left pane and grab the dns name of your load balancer</li>
  <li>Paste the dns name in your browser's URL bar and hit enter</li>
  <li>You should now see a "Hello World" meesage</li>
</ul>
