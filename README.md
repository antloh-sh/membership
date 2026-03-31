# AAC Members – Membership Lookup App

## Overview
This repository contains a lightweight web app for authenticated AAC staff to look up member details and next‑of‑kin (NOK) contacts from a Supabase backend.
The app is a single‑page HTML application deployed via GitHub Pages and uses Supabase Auth and RPC functions for secure data access.

## Features
- Email/password sign‑in using Supabase Auth with a simple login screen and password visibility toggle.
- Member search by name, NRIC or phone with debounced "Enter" handling and an empty‑state message when there are no results.
- Inline display of member details (name, NRIC, phone, address) and one‑click NOK expansion per member card.
- Terminated members are visually flagged with a red **Terminated** label on their search result card.
- Supabase RPC calls to `search_members_generic` and `get_member_nok` for server‑side filtering and NOK retrieval.
- Admin-only **Update Members** tab with a unified upload interface — select Member Details and/or Family Members CSV files and sync both to the database in one click.
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
- **RPC functions**: Ensure the database contains the following RPC functions with appropriate RLS policies:
  - `search_members_generic(search_term text)` — member search
  - `get_member_nok(reg_no text)` — NOK retrieval
  - `import_and_merge_members(import_data jsonb)` — upserts member details including `currentmembershipstatus`
  - `import_and_merge_family(import_data jsonb)` — upserts family member records

## Usage
1. Open the deployed app (GitHub Pages URL) in a modern browser.
2. Sign in using your allocated Supabase email/password account.
3. In **Member Search**, enter at least 2 characters of Name, NRIC or phone, then press Enter or click **Search**.
4. Click **NOK** on a member card to show or hide their recorded family contacts.
5. Members with a **Terminated** status will be flagged in red on their card.
6. Click **Sign Out**, or allow the app to auto‑logout after 15 minutes of inactivity.

### Updating member data (admin only)
1. Switch to the **Update Members** tab (visible to admin accounts only).
2. Select the **AACMemberDetails** CSV under *Member Details* and/or the **FamilyMembersListing** CSV under *Family Members* — either or both files can be uploaded in the same operation.
3. Tap **Upload & Sync**. Each selected file is processed and synced sequentially; a success or error message is shown per file.

## Database schema notes
### aac_members_details
Imported from the AACMemberDetails CSV:

| CSV column | DB column |
|---|---|
| `RegistrationDocumentNumber` | `registrationdocumentnumber` |
| `FullNameNative` | `fullnamenative` |
| `ToAddressAs` | `toaddressas` |
| `DateOfBirth` | `dateofbirth` |
| `Gender` | `gender` |
| `Phone` | `phone` |
| `ResidesWithinServiceBoundaryStr` | `resideswithinserviceboundarystr` |
| `FullAddress` | `fulladdress` |
| `CurrentMembershipStatus` | `currentmembershipstatus` |

### family_members
Imported from the FamilyMembersListing CSV:

| CSV column | DB column |
|---|---|
| `Patient_NRIC_Fin_Passport_No___` | `patientnricfinpassportno` |
| `Family_Member_Name__` | `familymembername` |
| `Relationship____To_follow_ILTC_Master_List_` | `relationshiptofollowiltcmasterlist` |
| `Home_Phone` | `homephone` |
| `Mobile_Phone` | `mobilephone` |

## Development notes
- All app logic (auth, search, NOK retrieval, ETL sync, idle timer) is implemented in inline `<script>` tags in `index.html`.
- Errors from Supabase RPC calls are surfaced in the UI message banner and logged to the console; use browser dev tools for debugging.
- Adjust the idle timeout, search debounce, and UI copy directly in the script section as needed.
