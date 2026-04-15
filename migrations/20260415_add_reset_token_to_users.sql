-- Migration: add password reset support to users table
-- Run this AFTER applying the base schema.sql

USE prison_management_db;

ALTER TABLE users
    ADD COLUMN reset_token VARCHAR(100) NULL AFTER password_salt,
    ADD COLUMN reset_token_expiry DATETIME NULL AFTER reset_token;
