import type { Metadata } from "next";
import { Noto_Sans_Arabic, Playfair_Display } from "next/font/google";
import "./globals.css";

const notoArabic = Noto_Sans_Arabic({
  subsets: ["arabic"],
  weight: ["300", "400", "500", "600", "700"],
  variable: "--font-noto-arabic",
});

const playfair = Playfair_Display({
  subsets: ["latin"],
  weight: ["400", "700"],
  variable: "--font-playfair",
});

export const metadata: Metadata = {
  title: "شهد — اشترِ الحين، ادفع على راحتك",
  description: "اشترِ الحين، ادفع على راحتك — 4 أقساط بدون فوائد. كن من الأوائل في الأردن.",
  openGraph: {
    title: "شهد — اشترِ الحين، ادفع على راحتك",
    description: "اشترِ الحين، ادفع على راحتك — 4 أقساط بدون فوائد. كن من الأوائل في الأردن.",
    locale: "ar_JO",
    type: "website",
  },
};

export const viewport = {
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl" className="scroll-smooth">
      <body className={`${notoArabic.variable} ${playfair.variable} font-sans antialiased bg-[var(--background)] text-[var(--foreground)]`}>
        {children}
      </body>
    </html>
  );
}
