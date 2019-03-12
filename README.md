# Deploying a cheap managed kubernetes cluster

This terraform code will deploy a 3 node cluster on GKE. It uses the [free-tier](https://cloud.google.com/free/) extensively so should cost a little over $5 a month.

The nodes are 3 f1-micro preemptible VMs each with 10GB of storage. The terraform backend is a GCS bucket, which you could skip and use local instead. Although, you get 5GB free a month and the state file for me was ~18KB...

Preemptible VMs actually aren't in the free tier so you could theoretically run one regular f1-micro for free and then 2 preemptible ones and it would be cheaper.

## Getting Started

I recommend following the GCP Terraform getting started guide [here](https://www.terraform.io/docs/providers/google/getting_started.html). It uses only free resources.

As a note, I had to export `GOOGLE_APPLICATION_CREDENTIALS` as the path to my credential file instead of `GOOGLE_CLOUD_KEYFILE_JSON` which is mentioned in the guide.

Create a Google Cloud Storage Regional bucket [this outlines requirements](https://cloud.google.com/storage/docs/naming#requirements)

You'll then need to fill out your own values in `terraform.tfvars.example` and `backend.hcl.example` and remove the `.example` extension.

1. `terraform init -backend-config=backend.hcl`
2. `terraform plan` This should output what will be created. Should be a cluster and node pool.
3. `terraform apply` This will create the resources
4. `terraform destroy` Don't forget to delete the resources if you don't need them

It takes awhile (like 8mins). It creates a cluster with the default node pool and then deletes it and replaces it with the node pool we specified.

**Caveats**
We disabled logging, monitoring and load balancing. All 3 can add quite a bit of $$$ with load balancing being ~$20 a month.