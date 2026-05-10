# شهد (Shahed) - Waitlist Landing Page

Luxury, minimal, and trustworthy landing page for "شهد" (Shahed), a Buy Now Pay Later (BNPL) app targeting Jordan.

## Tech Stack
- **Framework:** Next.js 14 (App Router)
- **Styling:** Tailwind CSS (v4)
- **Language:** TypeScript
- **Fonts:** Noto Sans Arabic (Arabic), Playfair Display (Logo)

## Features
- **Bilingual (AR/EN):** Focused on Jordanian market with primary Arabic interface.
- **Waitlist Form:** Phone validation (Jordanian format), store preference, and city selection.
- **Local Data Storage:** Submissions are saved to `data/waitlist.json`.
- **Responsive Design:** Premium mobile-first experience.
- **Luxury Aesthetic:** Deep gold (#C9A84C) and off-white (#FAFAF8) palette.

## Getting Started

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Run the development server:**
   ```bash
   npm run dev
   ```

3. **Open [http://localhost:3000](http://localhost:3000) in your browser.**

## API Endpoints
- `POST /api/waitlist`: Registers a new user.
  - Body: `{ phone: string, store: string, city: string }`

## Project Structure
- `app/`: Next.js App Router files.
- `components/`: Reusable UI components.
- `data/`: JSON storage for waitlist entries.
- `public/`: Static assets.

## Socials
- Instagram: [@shahed.jo](https://instagram.com/shahed.jo)

---
© 2025 شهد — جميع الحقوق محفوظة
