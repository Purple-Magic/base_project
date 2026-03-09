# GitHub Actions Workflows

This repository contains automated CI/CD workflows for the Timelog application.

## Available Workflows

### 1. CI (Continuous Integration)
**File**: `ci.yml`  
**Trigger**: Automatic on pull requests and pushes to main branch

Runs automated checks:
- Ruby security scanning (Brakeman)
- Gem vulnerability scanning (Bundler Audit)
- JavaScript security scanning (Importmap Audit)
- Code linting (RuboCop)
- Unit and integration tests (RSpec)
- System tests (Capybara)

### 2. Deploy to Staging
**File**: `deploy-staging.yml`  
**Trigger**: Manual (workflow_dispatch)

Deploys the application to a temporary staging environment on DigitalOcean.

## Using the Staging Deployment Workflow

### Prerequisites

Before you can use the staging deployment workflow, you need to configure the following GitHub repository secrets:

#### Required Secrets

1. **DigitalOcean Credentials**
   - `DIGITALOCEAN_TOKEN` - Your DigitalOcean API token
     - Get it from: https://cloud.digitalocean.com/account/api/tokens
     - Needs read/write permissions

2. **SSH Keys**
   - `SSH_PUBLIC_KEY` - Your SSH public key (for server access)
   - `SSH_PRIVATE_KEY` - Your SSH private key (for deployment)
   
   Generate a new key pair:
   ```bash
   ssh-keygen -t rsa -b 4096 -C "github-actions@timelog" -f ~/.ssh/timelog_deploy
   ```
   
   Then add to GitHub secrets:
   - Public key: `cat ~/.ssh/timelog_deploy.pub`
   - Private key: `cat ~/.ssh/timelog_deploy`

3. **Application Secrets**
   - `RAILS_MASTER_KEY` - Rails master key from `config/master.key`
   - `STAGING_AUTH0_CLIENT_ID` - Auth0 application client ID for staging
   - `STAGING_AUTH0_CLIENT_SECRET` - Auth0 application client secret for staging
   - `AUTH0_DOMAIN` - Your Auth0 domain (e.g., `your-tenant.auth0.com`)
   - `STAGING_POSTGRES_PASSWORD` - Strong password for PostgreSQL (generate with `openssl rand -base64 32`)

### How to Configure Secrets

1. Go to your GitHub repository
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret listed above

### Running the Deployment

#### Via GitHub UI

1. Go to your repository on GitHub
2. Click on the **Actions** tab
3. Select **Deploy to Staging** from the workflows list
4. Click **Run workflow** button
5. Fill in the parameters:
   - **Branch to deploy**: The branch you want to deploy (default: `main`)
   - **Destroy droplet after deployment test**: Choose `yes` to automatically destroy the droplet after testing, or `no` to keep it running
6. Click **Run workflow**

#### Via GitHub CLI

```bash
# Deploy main branch (keep droplet running)
gh workflow run deploy-staging.yml -f branch=main -f destroy_after=no

# Deploy feature branch and auto-destroy after testing
gh workflow run deploy-staging.yml -f branch=feature/new-feature -f destroy_after=yes

# Deploy specific branch
gh workflow run deploy-staging.yml -f branch=develop -f destroy_after=no
```

### Workflow Steps

The deployment workflow consists of three jobs:

#### 1. Create Infrastructure (`create-infrastructure`)
- Checks out the specified branch
- Sets up Terraform
- Creates a DigitalOcean droplet with:
  - Ubuntu 22.04
  - 1 vCPU, 2GB RAM (s-1vcpu-2gb)
  - Docker pre-installed
  - Firewall configured (SSH, HTTP, HTTPS)
- Waits for the droplet to be ready
- Outputs the droplet IP address

#### 2. Deploy Application (`deploy-application`)
- Checks out the specified branch
- Sets up Ruby and installs Kamal
- Configures SSH access to the droplet
- Updates Kamal configuration with the droplet IP
- Sets up environment secrets
- Deploys the application using Kamal
- Verifies the deployment

#### 3. Cleanup Infrastructure (`cleanup-infrastructure`)
- Runs only if `destroy_after=yes` was selected
- Downloads the Terraform state
- Destroys the DigitalOcean droplet
- Cleans up all resources

### Monitoring the Deployment

1. **Watch the workflow progress**
   - Go to Actions tab → Select the running workflow
   - View real-time logs for each job

2. **Access the deployed application**
   - The workflow output includes the staging URL
   - Example: `http://123.456.789.012`

3. **SSH into the server**
   - Use the SSH command from the workflow output
   - Example: `ssh root@123.456.789.012`

4. **View application logs**
   ```bash
   # After SSH'ing into the server
   docker ps
   docker logs <container-id>
   ```

### Manual Cleanup

If you kept the droplet running (`destroy_after=no`), you can manually destroy it:

1. **Via Terraform**
   ```bash
   # In your local repository
   cd terraform/staging
   terraform destroy
   ```

2. **Via DigitalOcean UI**
   - Go to https://cloud.digitalocean.com/droplets
   - Find the droplet named `timelog-staging-<run-number>`
   - Click **Destroy**

3. **Via GitHub Actions**
   - Run the workflow again with the same branch
   - Set `destroy_after=yes`
   - It will update the existing droplet or create a new one, then destroy it

### Cost Management

- **Droplet cost**: ~$0.018/hour or $12/month (s-1vcpu-2gb)
- **Recommendation**: Use `destroy_after=yes` for quick tests
- **For longer testing**: Keep the droplet running for a few hours, then manually destroy
- **Automatic cleanup**: The Terraform state artifact is kept for 7 days

### Troubleshooting

#### Workflow fails at "Create Infrastructure"
- Check that `DIGITALOCEAN_TOKEN` is valid and has correct permissions
- Verify SSH keys are properly formatted (no extra spaces or newlines)
- Check DigitalOcean account has available droplet quota

#### Workflow fails at "Deploy Application"
- Verify all application secrets are configured correctly
- Check that `RAILS_MASTER_KEY` matches your `config/master.key`
- Ensure Auth0 application is configured for the staging environment

#### Cannot SSH into server
- Wait a few minutes after deployment completes
- Check that your IP isn't blocked by DigitalOcean firewall
- Try using the DigitalOcean console access as fallback

#### Application not responding
- SSH into server and check Docker containers: `docker ps`
- View application logs: `docker logs <container-id>`
- Check Kamal logs: `kamal app logs -d staging`

### Best Practices

1. **Use feature branches**: Test changes on feature branches before merging to main
2. **Enable auto-destroy**: For quick tests, use `destroy_after=yes` to save costs
3. **Keep droplets short-lived**: Destroy staging environments when not actively testing
4. **Monitor costs**: Check your DigitalOcean usage regularly
5. **Secure secrets**: Never commit secrets to the repository
6. **Test before production**: Always test on staging before deploying to production

### Example Use Cases

#### Testing a Feature Branch
```bash
# Deploy feature branch, test it, and auto-destroy
gh workflow run deploy-staging.yml \
  -f branch=feature/new-payment-flow \
  -f destroy_after=yes
```

#### Pre-production Validation
```bash
# Deploy main branch and keep it running for validation
gh workflow run deploy-staging.yml \
  -f branch=main \
  -f destroy_after=no

# After validation, manually destroy via DigitalOcean UI or Terraform
```

#### Emergency Hotfix Testing
```bash
# Quickly deploy and test a hotfix branch
gh workflow run deploy-staging.yml \
  -f branch=hotfix/critical-bug \
  -f destroy_after=yes
```

## Adding More Workflows

To add new workflows:

1. Create a new YAML file in `.github/workflows/`
2. Follow GitHub Actions syntax
3. Test with a feature branch first
4. Document the workflow in this README

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Kamal Documentation](https://kamal-deploy.org/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [DigitalOcean API Documentation](https://docs.digitalocean.com/reference/api/)
