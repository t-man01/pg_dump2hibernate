--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: atable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE atable (
    note character varying(255) NOT NULL,
    id integer NOT NULL
);


ALTER TABLE atable OWNER TO postgres;

--
-- Data for Name: atable; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY atable (note, id) FROM stdin;
first	1
se"cond	2
third	3
fourth	4
\.


--
-- Name: atable atable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY atable
    ADD CONSTRAINT atable_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

