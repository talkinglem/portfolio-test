# Rommel Lasala — editable portfolio for Vercel

This is a standard Next.js website, separate from the ChatGPT-hosted edition. It includes Brand Design, Graphic Design and Social Media, Illustration, Poster Design, individual project pages, scroll reveals, parallax, and a private editor at /edit. No edit links appear in the portfolio. The first published project's cover is also the hero image.

## Deploy

1. Create a Supabase project at https://supabase.com/dashboard. Open its SQL Editor and run setup.sql. It creates the portfolio table, image metadata table, private artwork bucket, and sign-in throttling. No public database write policy is granted.
2. In Supabase project settings, copy the project URL and the legacy service_role API key. Keep this key private; it is only used on the server.
3. Upload this folder to your own GitHub repository. Keep .env files and keys out of GitHub. In Vercel, import the repository and choose Next.js.
4. Add four Vercel environment variables: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, ADMIN_PASSWORD (a unique password of at least 16 characters), and ADMIN_SESSION_SECRET (at least 32 random characters). Generate a session secret locally with `node -e "console.log(require('node:crypto').randomBytes(32).toString('hex'))"`.
5. Deploy. Visit /edit, sign in with your owner password, upload images, choose covers, arrange projects, and click Save changes. Add your contact email under About & contact.

Public visitors can view the portfolio and projects. Only a valid owner session can upload or save. Sessions are signed, expire after eight hours, and use Secure/HttpOnly/SameSite cookies in production. Changing the session secret signs out existing sessions. Sign-in attempts are throttled in the database to five attempts per 15-minute window per IP hash.

The Vercel edition accepts PNG, JPG, and WebP up to **3 MB per image** so uploads remain below Vercel Functions' 4.5 MB request limit. The editor shows that limit. Compress large full-page artwork before uploading. Project galleries retain original proportions. Your existing artwork stays in the ChatGPT-hosted portfolio; this package does not copy that live database or image bucket. Reupload your project images into Supabase after deployment.

## Local development

Copy .env.example to .env.local and fill its values. Run `npm install`, then `npm run dev`. `npm run build` creates the production Next.js build. A deployed Vercel URL is not included; deploy in your own Vercel account after connecting Supabase.

Without Supabase settings, the website displays its empty four-section portfolio, and the login page explains setup. Editing requires the configured backend; it never saves only in browser memory. Do not put service keys into NEXT_PUBLIC variables.

Official deployment documentation: https://vercel.com/docs/frameworks/full-stack/nextjs
Supabase dashboard: https://supabase.com/dashboard
Vercel payload limit: https://vercel.com/docs/functions/limitations
