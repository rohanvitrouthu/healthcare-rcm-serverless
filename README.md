# Healthcare Revenue Cycle Management (RCM) Data Platform

[![Python CI](https://github.com/rohanvitrouthu/healthcare-rcm/actions/workflows/ci-python.yml/badge.svg)](https://github.com/rohanvitrouthu/healthcare-rcm/actions/workflows/ci-python.yml)
[![Terraform CI/CD](https://github.com/rohanvitrouthu/healthcare-rcm/actions/workflows/terraform-cd.yml/badge.svg)](https://github.com/rohanvitrouthu/healthcare-rcm/actions/workflows/terraform-cd.yml)

An enterprise-grade, end-to-end data engineering platform for Healthcare Revenue Cycle Management. This project demonstrates the implementation of a modern, serverless data stack on Azure focusing on cost optimization, scalability, and robust orchestration.

## 🚀 Key Features & Architecture
- **Serverless Cloud Infrastructure**: Fully managed resources leveraging Azure Data Factory, Databricks, Azure SQL DB, and ADLS Gen 2.
- **Infrastructure as Code**: Entire Azure stack seamlessly managed via Terraform.
- **Data Orchestration**: Azure Data Factory configured to orchestrate, parameterize, and trigger data pipelines.
- **Data Processing**: Bronze -> Silver -> Gold layered architecture processing Claims and CPT data using Databricks / Delta Lake.
- **Source Simulation**: Containerized tools to generate synthetic medical data mimicking real Hospital SQL DBs.

## 📈 Roadmap and Progress
- ✅ **Phase 1**: Setup Dev Env, Terraform foundations, ADLS Gen2, and Azure Key Vault.
- ✅ **Phase 2**: Provision Azure SQL DBs (`HospitalA_DB`, `HospitalB_DB`) and generate synthetic claims data (~16k records).
- ✅ **Phase 3**: Deploy Azure Data Factory Linked Services and Datasets programmatically (IaC).
- 🔄 **Phase 4**: Configure Azure Data Factory to orchestrate data ingestion. *(In Progress)*
- ⏳ **Phase 5**: Databricks processing from Bronze to Silver delta layers.

## 📁 Repository Structure
```text
.
├── .github/workflows/   # CI/CD Pipelines
├── data_factory/        # ADF pipeline definitions and configurations
├── databricks/          # Databricks notebooks and Spark processing
├── docs/                # Detailed documentation and architecture
├── terraform/           # Infrastructure as Code (Azure)
└── tests/               # Unit and Integration tests
```

## 🛠 Tech Stack
- **Cloud**: Azure (Data Factory, Databricks, ADLS Gen2, Azure SQL, Key Vault)
- **IaC**: Terraform
- **Orchestration**: Azure Data Factory
- **Data Processing**: PySpark, Delta Lake
- **Languages**: Python, HCL, SQL

## 📖 Documentation
- [System Architecture](./docs/ARCHITECTURE.md)
- [How to Run Guide](./docs/HOW_TO_RUN.md)
- [Project Progress Summary](./GEMINI.md)

## 🏗 Getting Started

1. Clone the repository.
2. Set up Azure Service Principal and local configurations.
3. Initialize Terraform in `terraform/environments/dev`.
4. Run `terraform apply` to provision the ADF, Databricks, SQL, and ADLS resources.
5. Deploy Azure Data Factory pipelines and trigger them to run data processing.
