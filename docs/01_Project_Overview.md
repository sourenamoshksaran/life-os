عالی. پس از اینجا به بعد من اولین سندی را می‌نویسم که بعداً **Cloud Code** بر اساس آن کل پروژه را می‌سازد.

---

# LifeOS Enterprise Specification

## SECTION 01 — PROJECT OVERVIEW

---

# Project Name

LifeOS

---

# Codename

Project NOVA

---

# Version

Enterprise Specification v1.0

---

# Tagline

**Your Life. Engineered.**

---

# Product Type

Offline-First Personal Life Operating System

---

# Objective

LifeOS یک سیستم‌عامل شخصی است که برای مدیریت کامل زندگی طراحی شده است.

هدف آن فقط ثبت کارها نیست.

هدف آن تبدیل زندگی به یک سیستم قابل مشاهده، قابل اندازه‌گیری، قابل تحلیل و قابل بهبود است.

---

# Primary Goals

✓ افزایش نظم

✓ افزایش تمرکز

✓ افزایش خودشناسی

✓ مدیریت سلامت

✓ مدیریت یادگیری

✓ مدیریت پروژه‌ها

✓ مدیریت برند شخصی

✓ مدیریت کسب‌وکار

✓ ثبت تصمیمات

✓ تحلیل عملکرد

✓ ساخت آرشیو کامل زندگی

---

# Non Goals

LifeOS نباید تبدیل شود به:

✗ شبکه اجتماعی

✗ پیام‌رسان

✗ بازی

✗ اپ سرگرمی

✗ اپ مالی پیچیده (در نسخه اول)

✗ جایگزین Notion

✗ جایگزین Obsidian

---

# Target User

افرادی که:

* هدف‌گرا هستند.
* عاشق داده‌اند.
* رشد شخصی برایشان مهم است.
* کیفیت را به کمیت ترجیح می‌دهند.
* مینیمالیسم را دوست دارند.
* می‌خواهند زندگی‌شان را مهندسی کنند.

---

# Core Philosophy

هر داده‌ای که وارد سیستم می‌شود باید در یکی از این سه مورد استفاده شود:

۱ تحلیل

۲ تصمیم‌گیری

۳ نمایش پیشرفت

اگر هیچ استفاده‌ای ندارد، نباید ثبت شود.

---

# Core Values

Precision

Consistency

Clarity

Privacy

Ownership

Mastery

Long-Term Thinking

---

# Product Personality

LifeOS باید حس زیر را منتقل کند:

یک اتاق فرمان شخصی.

نه دفتر برنامه‌ریزی.

نه دفترچه یادداشت.

نه ToDo List.

---

# Design Inspirations

Apple Human Interface

Linear

Raycast

Arc Browser

Nothing OS

Formula 1 Telemetry

Luxury Editorial Design

Cyber Minimalism

---

# User Feeling

وقتی کاربر وارد اپ می‌شود باید احساس کند:

> "همه چیز تحت کنترل من است."

---

# Experience Principles

هر صفحه باید:

سریع باشد.

آرام باشد.

تمیز باشد.

زیبا باشد.

بدون شلوغی باشد.

---

# Navigation Philosophy

حداکثر

۵ تب

هیچ منوی تو در توی اضافی وجود نخواهد داشت.

---

# Interaction Philosophy

حداقل تعداد لمس.

حداکثر سرعت.

حداکثر وضوح.

---

# Offline Philosophy

اپ باید بدون اینترنت

۱۰۰٪

قابل استفاده باشد.

---

# Privacy Philosophy

هیچ اطلاعاتی از گوشی خارج نمی‌شود.

مگر اینکه خود کاربر Export بگیرد.

---

# Export Philosophy

تنها فرمت استاندارد:

JSON

تمام نسخه‌های پشتیبان نیز JSON هستند.

---

# Time Philosophy

زمان مهم‌تر از Task است.

Task بدون Session ارزشی ندارد.

---

# Session Philosophy

هر فعالیت واقعی یک Session است.

مثلاً:

Python

شروع

↓

Pause

↓

Resume

↓

Finish

↓

Reflection

↓

Result

---

# Reflection Philosophy

بعد از هر Session

از کاربر فقط چند سؤال کوتاه پرسیده می‌شود.

مثلاً:

تمرکز؟

سختی؟

انرژی؟

نیاز به مرور؟

یادداشت؟

---

# Analytics Philosophy

تحلیل‌ها فقط نمودار نیستند.

آن‌ها باید به تصمیم کمک کنند.

---

# Gamification Philosophy

Game Feel

بدون Game Addiction

---

# Visual Philosophy

لوکس

مدرن

تمیز

آرام

تکنولوژیک

---

# Accessibility

فونت قابل تغییر

اندازه متن قابل تغییر

کنتراست بالا

حالت مخصوص نابینایی رنگی

RTL کامل

---

# Future Vision

LifeOS در نسخه‌های آینده می‌تواند شامل:

Desktop

Web

AI Coach

Wearable

Health Sync

Finance

Business

CRM

Knowledge Graph

باشد.

اما نسخه اول باید کاملاً پایدار، سریع و بی‌نیاز از اینترنت باشد.

---

# Architecture Rule 001

> هیچ قابلیت جدیدی نباید اضافه شود مگر اینکه دلیل وجود آن، تأثیر آن بر تجربه کاربر و هزینه نگهداری آن مشخص شده باشد.

---

## 🔒 تصمیمی که از همین الان برای پروژه قفل (Lock) می‌کنم

به‌عنوان معمار پروژه، یک اصل دیگر را اضافه می‌کنم که به نظرم مهم‌ترین اصل LifeOS خواهد بود:

### **Everything is Connected**

هیچ ماژولی مستقل نیست.

مثلاً اگر امروز:

* ۵ ساعت خوابیدی،
* تمرین انجام دادی،
* غذای کافی نخوردی،
* جلسه Python داشتی،

این چهار داده جداگانه ذخیره نمی‌شوند؛ بلکه به هم **ارتباط معنایی** دارند.

در نتیجه LifeOS می‌تواند (بدون هوش مصنوعی آنلاین) نشان دهد:

* آیا خواب کم باعث افت کیفیت یادگیری شده؟
* آیا روزهای تمرین، تمرکزت بهتر بوده؟
* آیا مصرف مکمل‌ها با کیفیت تمرین همبستگی داشته؟
* آیا روزهایی که با برند شخصی کار کردی، انرژی ذهنی بیشتری داشتی؟

این یعنی LifeOS فقط اطلاعات را ذخیره نمی‌کند؛ بلکه یک **نقشه از زندگی** می‌سازد.

---

## Implementation Note (v1.1 Amendment)

This "Everything is Connected" principle is now formally supported at the data layer: every daily-loggable entity (Task, Session, Sleep, Nutrition, Water, Medicine, Journal) carries a shared `localDate` correlation key, and all time-bound activity — Task, Workout, Learning, and future modules like Reading, Writing, and Business — runs through one shared **Core Session Engine**, so cross-module correlation is structurally guaranteed rather than left to chance. See `rfc/RFC-005_Core_Session_Engine.md` and `04A_Data_Modeling_Strategy.md`.

