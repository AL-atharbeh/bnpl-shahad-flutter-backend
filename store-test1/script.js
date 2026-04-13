// Integration Constants
const STORE_ID = 5;
const PUBLIC_KEY = 'sh_pk_795894a435724ead8806090a';
const BACKEND_URL = 'https://enthusiastic-stillness-production-5dce.up.railway.app/api/v1';

// Product Data
const products = [
    {
        id: 1,
        name: "فستان صيفي راقي",
        category: "ملابس نسائية",
        price: 85,
        image: "assets/dress.png",
        badge: "الأكثر مبيعاً"
    },
    {
        id: 2,
        name: "بدلة رسمية كلاسيكية",
        category: "ملابس رجالية",
        price: 240,
        image: "assets/suit.png",
        badge: "عرض خاص"
    },
    {
        id: 3,
        name: "معطف شتوي فاخر",
        category: "ملابس شتوية",
        price: 180,
        image: "assets/coat.png"
    },
    {
        id: 4,
        name: "حذاء جلدي صناعة يدوية",
        category: "أحذية",
        price: 110,
        image: "assets/shoes.png"
    },
    {
        id: 5,
        name: "حقيبة يد عصرية",
        category: "إكسسوارات",
        price: 95,
        image: "assets/handbag.png",
        badge: "جديد"
    }
];

// App State
let cart = [];

// DOM Elements
const productsGrid = document.getElementById('products-grid');
const cartTrigger = document.getElementById('cart-trigger');
const cartDrawer = document.getElementById('cart-drawer');
const closeCart = document.getElementById('close-cart');
const overlay = document.getElementById('overlay');
const cartBody = document.getElementById('cart-body');
const cartCount = document.getElementById('cart-count');
const cartTotalPrice = document.getElementById('cart-total-price');
const checkoutBtn = document.getElementById('checkout-btn');
const toast = document.getElementById('toast');
const checkoutModal = document.getElementById('checkout-modal');
const closeModal = document.getElementById('close-modal');
const nextStepBtn = document.getElementById('next-step-btn');
const modalTitle = document.getElementById('modal-title');
const checkoutFormContent = document.getElementById('checkout-form-content');

// Initial Render
function init() {
    renderProducts();
    setupEventListeners();
}

// Render Products Grid
function renderProducts() {
    productsGrid.innerHTML = products.map(product => `
        <div class="product-card">
            ${product.badge ? `<div class="product-badge">${product.badge}</div>` : ''}
            <div class="product-image-container">
                <img src="${product.image}" alt="${product.name}">
            </div>
            <div class="product-info">
                <div class="product-category">${product.category}</div>
                <div class="product-name">${product.name}</div>
                <div class="product-price">${product.price} د.أ</div>
                <button class="btn btn-primary btn-add-cart" onclick="addToCart(${product.id})">إضافة للسلة</button>
            </div>
        </div>
    `).join('');
}

// Cart Logic
function addToCart(id) {
    const product = products.find(p => p.id === id);
    const existing = cart.find(item => item.id === id);

    if (existing) {
        existing.quantity += 1;
    } else {
        cart.push({ ...product, quantity: 1 });
    }

    updateCartUI();
    showToast();
}

function removeFromCart(id) {
    cart = cart.filter(item => item.id !== id);
    updateCartUI();
}

function updateCartUI() {
    // Update count
    const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
    cartCount.textContent = totalItems;

    // Update Body
    if (cart.length === 0) {
        cartBody.innerHTML = '<div class="empty-cart-message">حقيبتك فارغة حالياً</div>';
        checkoutBtn.disabled = true;
    } else {
        cartBody.innerHTML = cart.map(item => `
            <div class="cart-item">
                <img src="${item.image}" alt="${item.name}" class="cart-item-img">
                <div class="cart-item-details">
                    <div class="cart-item-name">${item.name}</div>
                    <div class="cart-item-price">${item.price} د.أ × ${item.quantity}</div>
                    <button class="remove-item" onclick="removeFromCart(${item.id})">إزالة</button>
                </div>
            </div>
        `).join('');
        checkoutBtn.disabled = false;
    }

    // Update Total
    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    cartTotalPrice.textContent = `${total} د.أ`;
}

// UI Interactions
function setupEventListeners() {
    cartTrigger.addEventListener('click', () => toggleCart(true));
    closeCart.addEventListener('click', () => toggleCart(false));
    overlay.addEventListener('click', () => {
        toggleCart(false);
        closeCheckoutModal();
    });

    checkoutBtn.addEventListener('click', openCheckoutModal);
    closeModal.addEventListener('click', closeCheckoutModal);

    nextStepBtn.addEventListener('click', handleNextStep);
}

function toggleCart(show) {
    if (show) {
        cartDrawer.classList.add('active');
        overlay.classList.add('active');
    } else {
        cartDrawer.classList.remove('active');
        overlay.classList.remove('active');
    }
}

function showToast() {
    toast.classList.add('active');
    setTimeout(() => {
        toast.classList.remove('active');
    }, 3000);
}

// Checkout Process
let currentStep = 1;
let checkoutData = {
    name: '',
    phone: '',
    address: '',
    paymentMethod: 'shahd'
};

function openCheckoutModal() {
    toggleCart(false);
    checkoutModal.classList.add('active');
    overlay.classList.add('active');
    currentStep = 1;
    updateModalContent();
}

function closeCheckoutModal() {
    checkoutModal.classList.remove('active');
    overlay.classList.remove('active');
}

function handleNextStep() {
    if (currentStep === 1) {
        // Collect shipping info
        checkoutData.name = document.getElementById('cust-name').value;
        checkoutData.phone = document.getElementById('cust-phone').value;
        checkoutData.address = document.getElementById('cust-address').value;

        if (!checkoutData.name || !checkoutData.phone) {
            alert('يرجى إكمال البيانات المطلوبة');
            return;
        }

        currentStep = 2;
        updateModalContent();
    } else if (currentStep === 2) {
        // Collect payment method
        const selectedMethod = document.querySelector('input[name="payment"]:checked').id;
        checkoutData.paymentMethod = selectedMethod;

        currentStep = 3;
        updateModalContent();
    } else {
        // Final Action
        if (checkoutData.paymentMethod === 'p3') {
            createRealBnplSession();
        } else {
            // Mock Success for COD
            cart = [];
            updateCartUI();
            closeCheckoutModal();
            alert('🎉 تم تقديم طلبك بنجاح! شكراً لاختيارك Luxe Couture.');
        }
    }
}

async function createRealBnplSession() {
    const totalAmount = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const orderId = 'LUXE-' + Date.now();
    const btn = document.getElementById('next-step-btn-dynamic');
    
    btn.disabled = true;
    btn.textContent = 'جاري إنشاء الجلسة...';

    try {
        const response = await fetch(`${BACKEND_URL}/sessions/create`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'x-api-key': PUBLIC_KEY
            },
            body: JSON.stringify({
                store_id: STORE_ID,
                store_order_id: orderId,
                total_amount: totalAmount,
                currency: 'JOD',
                customer_phone: checkoutData.phone,
                customer_name: checkoutData.name,
                items: cart.map(item => ({
                    name: item.name,
                    price: item.price,
                    quantity: item.quantity,
                    image: window.location.origin + '/store-test1/' + item.image
                })),
                success_url: window.location.origin + '/store-test1/?success=true',
                cancel_url: window.location.origin + '/store-test1/?cancelled=true'
            })
        });

        const data = await response.json();

        if (data.success) {
            // Redirect to the approval view using the URL provided by the backend
            // or build it if web_redirect_url is missing
            const redirectUrl = data.web_redirect_url || `${BACKEND_URL}/sessions/view/${data.session_id}`;
            window.location.href = redirectUrl;
        } else {
            throw new Error(data.message || 'فشل في إنشاء الجلسة');
        }
    } catch (error) {
        console.error('Session creation error:', error);
        alert('❌ خطأ في عملية الربط: ' + error.message);
        btn.disabled = false;
        btn.textContent = 'تأكيد وشراء عبر شهد';
    }
}

function updateModalContent() {
    const steps = document.querySelectorAll('.step');
    steps.forEach((s, idx) => {
        if (idx + 1 <= currentStep) s.classList.add('active');
        else s.classList.remove('active');
    });

    if (currentStep === 1) {
        modalTitle.textContent = "تفاصيل الشحن";
        checkoutFormContent.innerHTML = `
            <div class="form-group">
                <label>الاسم الكامل</label>
                <input type="text" placeholder="أدخل اسمك هنا..." id="cust-name" value="${checkoutData.name}">
            </div>
            <div class="form-group">
                <label>رقم الهاتف</label>
                <input type="tel" placeholder="07XXXXXXXX" id="cust-phone" value="${checkoutData.phone}">
            </div>
            <div class="form-group">
                <label>العنوان</label>
                <textarea placeholder="المدينة، الشارع، البناية..." id="cust-address">${checkoutData.address}</textarea>
            </div>
            <button class="btn btn-primary w-100" id="next-step-btn-dynamic">المتابعة للدفع</button>
        `;
    } else if (currentStep === 2) {
        modalTitle.textContent = "طريقة الدفع";
        checkoutFormContent.innerHTML = `
            <div class="form-group" style="border: 3px solid var(--accent); padding: 15px; border-radius: 12px; background: rgba(212, 175, 55, 0.1);">
                <input type="radio" name="payment" id="p3" checked>
                <label for="p3" style="display: inline; margin-right: 10px; font-weight: bold; color: var(--accent);">بالتقسيط عبر شهد (مفعل ✅)</label>
            </div>
            <div class="form-group" style="border: 2px solid #ddd; padding: 15px; border-radius: 12px; margin-bottom: 10px; margin-top: 15px;">
                <input type="radio" name="payment" id="p1">
                <label for="p1" style="display: inline; margin-right: 10px;">الدفع عند الاستلام</label>
            </div>
            <div class="form-group" style="border: 2px solid #ddd; padding: 15px; border-radius: 12px; opacity: 0.5;">
                <input type="radio" name="payment" id="p2" disabled>
                <label for="p2" style="display: inline; margin-right: 10px;">البطاقة الائتمانية (قريباً)</label>
            </div>
            <button class="btn btn-primary w-100" id="next-step-btn-dynamic">مراجعة الطلب</button>
        `;
    } else {
        modalTitle.textContent = "تأكيد الطلب";
        const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        const methodText = checkoutData.paymentMethod === 'p3' ? 'تقسيط عبر شهد' : 'الدفع عند الاستلام';
        checkoutFormContent.innerHTML = `
            <div style="text-align: right; margin-bottom: 20px;">
                <p><strong>عدد المواد:</strong> ${cart.length}</p>
                <p><strong>الإجمالي المطلوب:</strong> ${total} د.أ</p>
                <p><strong>طريقة الدفع:</strong> ${methodText}</p>
                <p><strong>رقم الهاتف:</strong> ${checkoutData.phone}</p>
            </div>
            <button class="btn btn-primary w-100" id="next-step-btn-dynamic">
                ${checkoutData.paymentMethod === 'p3' ? 'تأكيد وشراء عبر شهد' : 'تأكيد وشراء'}
            </button>
        `;
    }

    // Re-attach listener because we replaced the innerHTML
    document.getElementById('next-step-btn-dynamic').onclick = handleNextStep;
}

// Check for URL params
const urlParams = new URLSearchParams(window.location.search);
if (urlParams.get('success') === 'true') {
    alert('🎉 تم الدفع بنجاح عبر نظام شهد! شكراً لك.');
    window.history.replaceState({}, document.title, window.location.pathname);
} else if (urlParams.get('cancelled') === 'true') {
    alert('❌ تم إلغاء عملية الدفع.');
    window.history.replaceState({}, document.title, window.location.pathname);
}

// Start the app
init();
