"use client";

import { useState } from 'react';

export default function WaitlistForm() {
  const [formData, setFormData] = useState({
    phone: '',
    store: '',
    city: 'عمّان'
  });
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [message, setMessage] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setStatus('loading');
    
    try {
      const res = await fetch('/api/waitlist', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });
      
      const data = await res.json();
      
      if (data.success) {
        setStatus('success');
        setMessage("شكراً! سنتواصل معك عند الإطلاق 🎉");
      } else {
        setStatus('error');
        setMessage(data.message || 'حدث خطأ ما');
      }
    } catch (err) {
      setStatus('error');
      setMessage('فشل الاتصال بالخادم');
    }
  };

  if (status === 'success') {
    return (
      <div className="max-w-md mx-auto p-10 bg-white rounded-3xl shadow-2xl border border-gold/10 text-center animate-fade-in">
        <div className="w-20 h-20 bg-gold/10 text-gold rounded-full flex items-center justify-center mx-auto mb-6 text-4xl">
          ✨
        </div>
        <h3 className="text-2xl font-bold text-luxury-black mb-3">{message}</h3>
        <p className="text-gray-500">تم حفظ بياناتك بنجاح، ترقبوا أخبارنا قريباً عبر الرسائل النصية.</p>
      </div>
    );
  }

  return (
    <div className="max-w-md mx-auto p-8 md:p-10 bg-white rounded-3xl shadow-2xl border border-gold/10 animate-slide-up" style={{ animationDelay: '0.4s' }}>
      <form onSubmit={handleSubmit} className="space-y-6">
        <div>
          <label htmlFor="phone" className="block text-sm font-bold text-gray-700 mb-2">رقم الهاتف</label>
          <input
            id="phone"
            type="tel"
            required
            placeholder="07XXXXXXXX"
            className="w-full px-5 py-4 rounded-2xl border border-gray-100 bg-gray-50/50 focus:bg-white focus:border-gold focus:ring-4 focus:ring-gold/5 outline-none transition-all text-left dir-ltr text-lg"
            value={formData.phone}
            onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
          />
          <p className="text-xs text-gray-400 mt-2">مثال: 0791234567</p>
        </div>

        <div>
          <label htmlFor="store" className="block text-sm font-bold text-gray-700 mb-2">المتجر المفضل</label>
          <input
            id="store"
            type="text"
            required
            placeholder="أين تتسوق عادةً؟"
            className="w-full px-5 py-4 rounded-2xl border border-gray-100 bg-gray-50/50 focus:bg-white focus:border-gold focus:ring-4 focus:ring-gold/5 outline-none transition-all text-lg"
            value={formData.store}
            onChange={(e) => setFormData({ ...formData, store: e.target.value })}
          />
        </div>

        <div>
          <label htmlFor="city" className="block text-sm font-bold text-gray-700 mb-2">المدينة</label>
          <div className="relative">
            <select
              id="city"
              className="w-full px-5 py-4 rounded-2xl border border-gray-100 bg-gray-50/50 focus:bg-white focus:border-gold focus:ring-4 focus:ring-gold/5 outline-none transition-all appearance-none text-lg"
              value={formData.city}
              onChange={(e) => setFormData({ ...formData, city: e.target.value })}
            >
              <option value="عمّان">عمّان</option>
              <option value="إربد">إربد</option>
              <option value="الزرقاء">الزرقاء</option>
              <option value="أخرى">أخرى</option>
            </select>
            <div className="absolute left-5 top-1/2 -translate-y-1/2 pointer-events-none text-gray-400">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
              </svg>
            </div>
          </div>
        </div>

        {status === 'error' && (
          <div className="p-4 bg-red-50 rounded-xl text-red-600 text-sm font-medium border border-red-100">
            {message}
          </div>
        )}

        <button
          type="submit"
          disabled={status === 'loading'}
          className="w-full py-5 bg-gold hover:bg-luxury-black text-white font-bold rounded-2xl shadow-xl shadow-gold/20 transition-all transform hover:-translate-y-1 active:scale-[0.98] disabled:opacity-70 disabled:cursor-not-allowed text-lg"
        >
          {status === 'loading' ? (
            <span className="flex items-center justify-center">
              <svg className="animate-spin h-5 w-5 ml-3 text-white" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              جاري التسجيل...
            </span>
          ) : 'سجّل اهتمامك'}
        </button>
      </form>
    </div>
  );
}
