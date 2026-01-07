# AAC Members – Membership Lookup App

## Overview
This repository contains a lightweight web app for authenticated AAC staff to look up member details and next‑of‑kin (NOK) contacts from a Supabase backend.   
The app is a single‑page HTML application deployed via GitHub Pages and uses Supabase Auth and RPC functions for secure data access.   

## Features
- Email/password sign‑in using Supabase Auth with a simple login screen and password visibility toggle.   
- Member search by name, NRIC or phone with debounced “Enter” handling and an empty‑state message when there are no results.   
- Inline display of member details (name, NRIC, phone, address) and one‑click NOK expansion per member card.   
- Supabase RPC calls to `search_members_generic` and `get_member_nok` for server‑side filtering and NOK retrieval.   
- Automatic idle logout after 15 minutes of inactivity and explicit sign‑out that redirects back to the public GitHub Pages URL.   

## Tech stack
- **Frontend**: Plain HTML, CSS, and vanilla JavaScript in a single `index.html` file.   
- **Backend**: Supabase (PostgreSQL + Auth + Edge Functions/RPC) accessed via `@supabase/supabase-js@2` CDN bundle.   
- **Hosting**: GitHub Pages served from this repository and referenced via `https://antloh-sh.github.io/membership/`.   

## Configuration
Before deployment, set up the following in `index.html`:   

- **Supabase URL**: Replace `SUPABASE_URL` with the project URL from your Supabase dashboard if different.   
- **Anon/public key**: Ensure `SUPABASE_ANON_KEY` uses a publishable key, not a service role key.   
- **GitHub Pages URL**: Update `GITHUB_URL` if you fork or rename the repository, so sign‑out redirects correctly.   
- **RPC functions**: Ensure the database contains the `search_members_generic(search_term text)` and `get_member_nok(reg_no text)` RPC functions with appropriate RLS policies.   

## Usage
1. Open the deployed app (GitHub Pages URL) in a modern browser.   
2. Sign in using your allocated Supabase email/password account.   
3. In **Member Search**, enter at least 2 characters of Name, NRIC or phone, then press Enter or click **Search**.   
4. Click **NOK** on a member card to show or hide their recorded family contacts.   
5. Click **Sign Out**, or allow the app to auto‑logout after 15 minutes of inactivity.   

## Development notes
- All app logic (auth, search, NOK retrieval, idle timer) is implemented in inline `<script>` tags in `index.html`.   
- Errors from Supabase RPC calls are logged to the console; use browser dev tools for debugging.   
- Adjust the idle timeout, search debounce, and UI copy directly in the script section as needed.   
