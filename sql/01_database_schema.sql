-- =========================================================
-- EdTech Analytics
-- File: 01_database_schema.sql
-- Purpose: Create the six core PostgreSQL tables and define their primary-key / foreign-key relationships.
-- =========================================================


CREATE TABLE programmes (
    programme_id VARCHAR(10) PRIMARY KEY,
    programme_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price NUMERIC(10,2),
    duration_weeks INTEGER
);


CREATE TABLE campaigns (
    campaign_id VARCHAR(10) PRIMARY KEY,
    campaign_name VARCHAR(100),
    channel VARCHAR(50),
    start_date DATE,
    end_date DATE,
    campaign_spend NUMERIC(10,2),
    impressions INTEGER,
    clicks INTEGER
);


CREATE TABLE leads (
    lead_id VARCHAR(10) PRIMARY KEY,
    created_date DATE,
    age_group VARCHAR(10),
    education_level VARCHAR(30),
    employment_status VARCHAR(30),
    country VARCHAR(30),
    acquisition_channel VARCHAR(50),
    programme_interest VARCHAR(10),
    campaign_id VARCHAR(10),

    FOREIGN KEY (programme_interest)
        REFERENCES programmes(programme_id),

    FOREIGN KEY (campaign_id)
        REFERENCES campaigns(campaign_id)
);


CREATE TABLE interactions (
    interaction_id VARCHAR(10) PRIMARY KEY,
    lead_id VARCHAR(10) NOT NULL,
    interaction_date DATE,
    interaction_type VARCHAR(30),
    staff_contacted VARCHAR(50),
    outcome VARCHAR(30),

    FOREIGN KEY (lead_id)
        REFERENCES leads(lead_id)
);


CREATE TABLE enrolments (
    enrolment_id VARCHAR(10) PRIMARY KEY,
    lead_id VARCHAR(10) NOT NULL,
    programme_id VARCHAR(10) NOT NULL,
    enrolment_date DATE,
    status VARCHAR(30),
    completion_date DATE,

    FOREIGN KEY (lead_id)
        REFERENCES leads(lead_id),

    FOREIGN KEY (programme_id)
        REFERENCES programmes(programme_id)
);


CREATE TABLE payments (
    payment_id VARCHAR(10) PRIMARY KEY,
    enrolment_id VARCHAR(10) NOT NULL,
    payment_date DATE,
    amount NUMERIC(10,2),
    payment_method VARCHAR(30),
    payment_status VARCHAR(20),
    refund_amount NUMERIC(10,2),

    FOREIGN KEY (enrolment_id)
        REFERENCES enrolments(enrolment_id)
);
