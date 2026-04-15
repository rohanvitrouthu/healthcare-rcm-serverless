# System Architecture

## Overview
The Healthcare RCM Data Platform is built on a modular, cloud-native architecture using Azure services. It follows the Medallion Architecture pattern for data processing.

## High-Level Architecture Diagram
```mermaid
graph TD
    subgraph "External Sources"
        NPI[NPI Registry API]
        ICD[ICD-10 Code Source]
        CPT[CPT Code Source]
    end

    subgraph "Azure Data Platform"
        subgraph "Azure Data Factory"
            ADF[Azure Data Factory]
            PIPELINES[Pipelines: NPI, ICD, CPT Pipeline]
        end

        subgraph "Containerized Tasks"
            EXT[Extractors]
            PROC[Bronze Processor]
            DQ[Great Expectations]
        end
    end

    subgraph "Storage (ADLS Gen2)"
        BRONZE[Bronze Zone - Parquet/JSON]
        SILVER[Silver Zone - Cleaned]
    end

    ADF -->|Triggers| EXT
    EXT -->|Fetch Data| NPI
    EXT -->|Write Raw| BRONZE
    ADF -->|Triggers| PROC
    PROC -->|Read Raw| BRONZE
    PROC -->|Validate| DQ
    PROC -->|Write Parquet| BRONZE
    
```

## Component Details

### 1. Ingestion Layer
- **Extractors**: Containerized Python applications.
- **NPI Extractor**: Fetches data from the NPPES NPI Registry API.
- **ICD/CPT Extractors**: Simulated or API-based extractors for medical codes.
- **Orchestration**: Managed by Azure Data Factory.

### 2. Storage Layer (ADLS Gen2)
- **Bronze**: Raw data in its original format (JSON) and initial Parquet conversion.
- **Silver**: (Planned) Cleaned and standardized data.
- **Gold**: (Planned) Aggregated data for analytics.

### 3. Processing & Quality
- **Bronze Processor**: Converts raw JSON to optimized Parquet format.
- **Data Quality**: Integrated Great Expectations (GX) checkpoints to ensure schema validation and data integrity.

### 4. CI/CD
- **GitHub Actions**: Automates linting, Docker builds, and Infrastructure as Code (Terraform) deployments.
