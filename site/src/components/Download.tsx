import { motion } from "framer-motion";
import { Apple, Smartphone } from "lucide-react";

export function Download() {
  return (
    <section id="download" className="py-24 px-6 overflow-hidden">
      <div className="max-w-5xl mx-auto rounded-[2.5rem] bg-primary p-12 lg:p-20 relative overflow-hidden text-white">
        {/* Decorative blobs */}
        <div className="absolute top-0 right-0 w-96 h-96 bg-white/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2" />
        <div className="absolute bottom-0 left-0 w-64 h-64 bg-black/10 rounded-full blur-3xl translate-y-1/2 -translate-x-1/2" />

        <div className="relative z-10 flex flex-col items-center text-center">
          <h2 className="text-display sm:text-5xl font-bold mb-6">
            Ready to speak FlowLingo?
          </h2>
          <p className="text-white/80 text-lg sm:text-xl max-w-2xl mx-auto mb-12">
            Join thousands of users communicating across borders every day. Download the keyboard now and start your free trial.
          </p>
          
          <div className="flex flex-col sm:flex-row gap-6 w-full justify-center">
            <a 
              href="#" 
              className="flex items-center justify-center gap-3 bg-white text-primary px-8 py-4 rounded-standard font-bold text-lg hover:bg-white/90 transition-colors shadow-xl"
            >
              <Apple className="w-6 h-6" />
              <div className="text-left leading-tight">
                <p className="text-[10px] uppercase tracking-wider font-medium opacity-70">Download on the</p>
                <p>App Store</p>
              </div>
            </a>
            <a 
              href="#" 
              className="flex items-center justify-center gap-3 bg-black/20 backdrop-blur-md text-white border border-white/20 px-8 py-4 rounded-standard font-bold text-lg hover:bg-black/30 transition-colors shadow-xl"
            >
              <Smartphone className="w-6 h-6" />
              <div className="text-left leading-tight">
                <p className="text-[10px] uppercase tracking-wider font-medium opacity-70">Get it on</p>
                <p>Google Play</p>
              </div>
            </a>
          </div>
          
          <p className="mt-10 text-white/60 text-sm font-medium">
            Available in 50+ languages. Requires iOS 15+ or Android 10+.
          </p>
        </div>
      </div>
    </section>
  );
}
