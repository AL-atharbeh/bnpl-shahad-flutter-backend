"use client";

import Image from "next/image";

export default function Hero() {
  return (
    <section className="relative pt-12 pb-16 md:pt-24 md:pb-24 overflow-hidden">
      <div className="container mx-auto px-4 text-center">
        <div className="flex justify-center mb-10 animate-fade-in">
          <Image 
            src="/logo.png" 
            alt="شهد - Shahed" 
            width={180} 
            height={180} 
            className="animate-float drop-shadow-2xl"
            priority
          />
        </div>
        
        <div className="space-y-4 animate-slide-up" style={{ animationDelay: '0.2s' }}>
          <h2 className="text-4xl md:text-7xl font-bold text-primary leading-tight">
            اشترِ الحين، ادفع على راحتك
          </h2>
          <p className="text-xl md:text-3xl text-primary-light/80 font-medium">
            Buy Now, Pay in 4 — Zero Interest
          </p>
          <div className="inline-block px-8 py-3 bg-primary text-white rounded-full text-lg md:text-xl mt-8 font-bold shadow-xl shadow-primary/20">
            كن من الأوائل في الأردن 🇯🇴
          </div>
        </div>
      </div>
      
      {/* Decorative Background Elements */}
      <div className="absolute top-0 left-0 w-96 h-96 bg-primary/5 rounded-full blur-[120px] -translate-x-1/2 -translate-y-1/2"></div>
      <div className="absolute bottom-0 right-0 w-[500px] h-[500px] bg-accent/5 rounded-full blur-[150px] translate-x-1/3 translate-y-1/3"></div>
    </section>
  );
}
