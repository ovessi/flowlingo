import { motion } from "framer-motion";
import { Apple, Smartphone, Sparkles } from "lucide-react";

export function Hero() {
  return (
    <section className="relative flex flex-col items-center justify-center pt-32 pb-16 px-6 text-center lg:pt-48 lg:pb-32 overflow-hidden">
      {/* Background Decorative elements */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full h-full -z-10 pointer-events-none">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-primary/10 blur-[120px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-secondary/10 blur-[120px]" />
      </div>

      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="inline-flex items-center gap-2 rounded-full bg-primary/10 px-4 py-1.5 text-sm font-medium text-primary ring-1 ring-inset ring-primary/20 mb-8"
      >
        <Sparkles className="w-4 h-4" />
        <span>Next-gen AI Communication</span>
      </motion.div>

      <motion.h1 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.1 }}
        className="text-display sm:text-6xl md:text-7xl font-bold tracking-tight text-neutral-text-high dark:text-dark-text-high max-w-4xl mx-auto mb-8 leading-[1.1]"
      >
        Your keyboard, <br />
        <span className="text-primary">perfectly fluent.</span>
      </motion.h1>

      <motion.p 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.2 }}
        className="text-lg sm:text-xl text-neutral-text-low dark:text-dark-text-low max-w-2xl mx-auto mb-12 leading-relaxed"
      >
        FlowLingo translates, localizes, and adjusts tone across 50+ languages inside any app. No more switching tools—just seamless connection.
      </motion.p>

      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.3 }}
        className="flex flex-col sm:flex-row gap-4 justify-center items-center w-full max-w-md mx-auto"
      >
        <a 
          href="#download" 
          className="w-full sm:w-auto flex items-center justify-center gap-2 rounded-standard bg-primary px-8 py-4 text-lg font-semibold text-white shadow-lg hover:bg-primary/90 hover:-translate-y-0.5 transition-all active:scale-95"
        >
          <Apple className="w-5 h-5" />
          <span>App Store</span>
        </a>
        <a 
          href="#download" 
          className="w-full sm:w-auto flex items-center justify-center gap-2 rounded-standard bg-neutral-surface dark:bg-dark-surface px-8 py-4 text-lg font-semibold text-neutral-text-high dark:text-dark-text-high shadow-md hover:bg-neutral-surface/80 dark:hover:bg-dark-surface/80 hover:-translate-y-0.5 transition-all border border-neutral-text-low/10 active:scale-95"
        >
          <Smartphone className="w-5 h-5" />
          <span>Play Store</span>
        </a>
      </motion.div>
      
      {/* Keyboard Mockup Preview */}
      <motion.div 
        initial={{ opacity: 0, y: 40 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.7, delay: 0.4 }}
        className="mt-20 w-full max-w-5xl mx-auto relative group"
      >
        <div className="absolute inset-0 bg-primary/20 blur-[100px] -z-10 group-hover:bg-primary/30 transition-colors duration-500" />
        <div className="rounded-2xl overflow-hidden shadow-2xl border border-neutral-text-low/20 bg-white/50 dark:bg-black/50 backdrop-blur-sm aspect-[16/10] flex items-center justify-center p-4">
           <div className="w-full h-full rounded-xl bg-neutral-surface dark:bg-dark-surface border border-neutral-text-low/10 flex flex-col">
              {/* Mock App UI */}
              <div className="flex-1 p-8 flex flex-col justify-end gap-4">
                 <div className="flex justify-start">
                    <div className="bg-neutral-surface dark:bg-dark-surface p-4 rounded-2xl rounded-bl-none border border-neutral-text-low/10 max-w-[80%]">
                       <p className="text-sm opacity-60 mb-1">Spanish</p>
                       <p>Hola, ¿cómo va el proyecto? ¿Necesitas ayuda con algo hoy?</p>
                    </div>
                 </div>
                 <div className="flex justify-end">
                    <div className="bg-primary p-4 rounded-2xl rounded-br-none text-white max-w-[80%] shadow-md">
                       <p className="text-sm opacity-80 mb-1">English (AI Translated)</p>
                       <p>Hey, how's the project going? Do you need help with anything today?</p>
                    </div>
                 </div>
              </div>
              {/* FlowLingo Keyboard Mockup */}
              <div className="bg-[#f0f0f5] dark:bg-[#1a1a1f] p-4 border-t border-neutral-text-low/20">
                 <div className="flex items-center gap-3 mb-4 overflow-x-auto pb-2 no-scrollbar">
                    <div className="bg-primary text-white px-4 py-1.5 rounded-full text-sm font-medium whitespace-nowrap shadow-sm">
                       Translate: EN → ES
                    </div>
                    <div className="bg-white dark:bg-neutral-surface px-4 py-1.5 rounded-full text-sm font-medium whitespace-nowrap border border-neutral-text-low/10">
                       Tone: Casual
                    </div>
                    <div className="bg-white dark:bg-neutral-surface px-4 py-1.5 rounded-full text-sm font-medium whitespace-nowrap border border-neutral-text-low/10 flex items-center gap-1">
                       <Sparkles className="w-3.5 h-3.5 text-primary" />
                       Analyze Context
                    </div>
                 </div>
                 <div className="grid grid-cols-10 gap-1.5">
                    {Array.from({ length: 30 }).map((_, i) => (
                      <div key={i} className="h-10 bg-white dark:bg-[#2d2d35] rounded-md border-b-2 border-neutral-text-low/20 shadow-sm" />
                    ))}
                 </div>
              </div>
           </div>
        </div>
      </motion.div>
    </section>
  );
}
