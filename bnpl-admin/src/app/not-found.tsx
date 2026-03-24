export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-950 text-slate-50">
      <div className="text-center space-y-2">
        <p className="text-xs font-semibold tracking-wide text-emerald-400 uppercase">
          404 - Page not found
        </p>
        <h1 className="text-lg font-semibold">This page does not exist.</h1>
        <p className="text-xs text-slate-400">
          Please check the URL or go back to your dashboard.
        </p>
      </div>
    </div>
  );
}


