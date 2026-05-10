"use client";

export default function HowItWorks() {
  const steps = [
    {
      number: "١",
      title: "اختر ما تريد شراءه",
      desc: "تسوق من متاجرك المفضلة في الأردن بكل سهولة ويسر"
    },
    {
      number: "٢",
      title: "ادفع الربع الأول فقط",
      desc: "قسّم قيمة مشترياتك على ٤ دفعات متساوية ومريحة"
    },
    {
      number: "٣",
      title: "والباقي على 3 أقساط",
      desc: "بدون فوائد، بدون رسوم خفية، وبشفافية كاملة"
    }
  ];

  return (
    <section className="py-24 md:py-36 bg-mint/10">
      <div className="container mx-auto px-4">
        <div className="text-center mb-24">
          <h3 className="text-3xl md:text-5xl font-black text-primary mb-6">كيف يعمل شهد؟</h3>
          <p className="text-primary-light font-medium text-lg">ثلاث خطوات بسيطة لبداية جديدة</p>
          <div className="w-24 h-2 bg-primary mx-auto rounded-full mt-6"></div>
        </div>
        
        <div className="grid md:grid-cols-3 gap-16 relative">
          {/* Connector Line (Desktop) */}
          <div className="hidden md:block absolute top-14 left-[15%] right-[15%] h-1 bg-primary/10 -z-10 rounded-full"></div>
          
          {steps.map((step, idx) => (
            <div key={idx} className="text-center group animate-fade-in" style={{ animationDelay: `${0.6 + idx * 0.2}s` }}>
              <div className="w-24 h-24 bg-white border-4 border-mint text-primary text-4xl font-black flex items-center justify-center rounded-[2rem] mx-auto mb-10 shadow-2xl group-hover:bg-primary group-hover:text-white transition-all duration-500 transform group-hover:-translate-y-4 group-hover:rotate-6">
                {step.number}
              </div>
              <h4 className="text-2xl font-bold mb-5 text-primary">{step.title}</h4>
              <p className="text-primary-light/80 text-xl leading-relaxed max-w-[280px] mx-auto font-medium">{step.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
