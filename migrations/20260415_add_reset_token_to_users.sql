-- Migration: align existing DB with DAO/model expectations
-- Safe to run on MySQL 8+ after applying base schema.sql

USE prison_management_db;

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS reset_token VARCHAR(100) NULL AFTER password_salt,
    ADD COLUMN IF NOT EXISTS reset_token_expiry DATETIME NULL AFTER reset_token;

ALTER TABLE prisoners
    ADD COLUMN IF NOT EXISTS photo_data_uri LONGTEXT AFTER emergency_contact;
