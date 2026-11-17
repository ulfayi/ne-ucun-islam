# Nə üçün İslam?

Mənbə sənədlərindən avtomatik çıxarılan məzmunla hazırlanan statik, mobil-uyğun editorial saytıdır.

## Windows-da başladın

```powershell
npm run build
npm run dev
```

`npx serve .` ünvanını brauzerdə açın. Sənədləri dəyişdirdikdən sonra Windows kompüterinizdə `npm run extract` işlədin və yaranan `public/content.json` faylını repozitoriyaya əlavə edin. Deploy build-i həmin hazır statik məzmundan istifadə edir; buna görə Vercel-də PowerShell tələb olunmur.

## Deploy

- **Netlify:** repozitoriyanı qoşun; build command `npm run build`, publish directory `.`. `netlify.toml` hazırdır.
- **Vercel:** repozitoriyanı import edin; build command `npm run build`, output directory `dist`. SPA keçidləri `vercel.json` ilə yönləndirilir.

Orijinal DOCX fayllar `sources/` qovluğunda qalır və sayt tərəfindən dərc edilmir. `public/content.json` yalnız məqalə mətni üçün qurulmuş çıxarışdır.
