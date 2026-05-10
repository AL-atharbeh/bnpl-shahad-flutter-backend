"use client";

export default function HowItWorks() {
  const steps = [
    {
      number: "١",
      title: "اختر ما تريد شراءه",
      desc: "تسوق من متاجرك المفضلة في الأردن بكل سهولة"
    },
    {
      number: "٢",
      title: "ادفع الربع الأول فقط",
      desc: "قسّم قيمة مشترياتك على ٤ دفعات متساوية"
    },
    {
      number: "٣",
      title: "والباقي على 3 أقساط",
      desc: "بدون فوائد، بدون رسوم خفية، وبكل شفافية"
    }
  ];

  return (
    <section className="py-24 md:py-32 bg-white/50">
      <div className="container mx-auto px-4">
        <div className="text-center mb-20">
          <h3 className="text-3xl md:text-5xl font-bold text-luxury-black mb-4">كيف يعمل "شهد"؟</h3>
          <div className="w-24 h-1.5 bg-gold mx-auto rounded-full"></div>
        </div>
        
        <div className="grid md:grid-cols-3 gap-16 relative">
          {/* Connector Line (Desktop) */}
          <div className="hidden md:block absolute top-12 left-[15%] right-[15%] h-0.5 bg-gray-100 -z-10"></div>
          
          {steps.map((step, idx) => (
            <div key={idx} className="text-center group animate-fade-in" style={{ animationDelay: `${0.6 + idx * 0.2}s` }}>
              <div className="w-20 h-20 bg-white border-2 border-gold text-gold text-3xl font-bold flex items-center justify-center rounded-3xl mx-auto mb-8 shadow-xl group-hover:bg-gold group-hover:text-white transition-all duration-500 transform group-hover:-translate-y-2">
                {step.number}
              </div>
              <h4 className="text-2xl font-bold mb-4 text-luxury-black">{step.title}</h4>
              <p className="text-gray-500 text-lg leading-relaxed max-w-[250px] mx-auto">{step.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
