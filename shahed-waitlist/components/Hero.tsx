"use client";

export default function Hero() {
  return (
    <section className="relative pt-20 pb-16 md:pt-32 md:pb-24 overflow-hidden">
      <div className="container mx-auto px-4 text-center">
        <h1 className="font-serif text-6xl md:text-9xl text-gold mb-8 animate-fade-in tracking-tight">
          شهد
        </h1>
        <div className="space-y-4 animate-slide-up" style={{ animationDelay: '0.2s' }}>
          <h2 className="text-4xl md:text-6xl font-bold text-luxury-black leading-tight">
            اشترِ الحين، ادفع على راحتك
          </h2>
          <p className="text-xl md:text-3xl text-gray-500 font-medium">
            Buy Now, Pay in 4 — Zero Interest
          </p>
          <div className="inline-block px-6 py-2 bg-gold/10 text-gold rounded-full text-lg md:text-xl mt-8 font-semibold">
            كن من الأوائل في الأردن
          </div>
        </div>
      </div>
      
      {/* Decorative Background Elements */}
      <div className="absolute top-0 left-0 w-64 h-64 bg-gold/5 rounded-full blur-[100px] -translate-x-1/2 -translate-y-1/2"></div>
      <div className="absolute bottom-0 right-0 w-96 h-96 bg-gold/5 rounded-full blur-[120px] translate-x-1/3 translate-y-1/3"></div>
    </section>
  );
}
