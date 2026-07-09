<script lang="ts">
  import Icon from '@iconify/svelte';
  import { Button } from '$lib/components/ui/button/index.js';
  import * as Card from '$lib/components/ui/card/index.js';
  import { toast } from 'svelte-sonner';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';

  let { data } = $props();
  const user = $derived(data.user);

  let loggingOut = $state(false);
  let purchasesUrl = $state('http://localhost:5174/');
  let posUrl = $state('http://localhost:3011/');

  onMount(() => {
    purchasesUrl = `${window.location.protocol}//${window.location.hostname}:5174/`;
    posUrl = `${window.location.protocol}//${window.location.hostname}:3011/`;
  });

  async function handleLogout() {
    loggingOut = true;
    try {
      const response = await fetch('/service/auth/logout', {
        method: 'POST'
      });
      if (response.ok) {
        toast.success('Logged out successfully');
        goto('/login');
      } else {
        toast.error('Logout failed.');
      }
    } catch (e) {
      toast.error('Logout connection error.');
    } finally {
      loggingOut = false;
    }
  }
</script>

<svelte:head>
  <title>Select Application — Cerpsys Platform</title>
</svelte:head>

<main class="min-h-screen w-full flex flex-col items-center justify-center bg-gradient-to-tr from-teal-dark via-[#1d5952] to-green-muted p-4 sm:p-6 relative">
  <!-- Decorative background glow -->
  <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-mint-pale/10 via-transparent to-transparent pointer-events-none"></div>

  <!-- Logout Button positioned at top right -->
  <div class="absolute top-4 right-4 sm:top-6 sm:right-6">
    <Button
      variant="outline"
      onclick={handleLogout}
      disabled={loggingOut}
      class="bg-white/10 hover:bg-white/20 border-white/20 hover:border-white/30 text-white font-semibold flex items-center gap-1.5 h-10 backdrop-blur-md rounded-xl transition-all"
    >
      {#if loggingOut}
        <Icon icon="mdi:loading" class="animate-spin" width="16" />
      {:else}
        <Icon icon="mdi:logout" width="16" />
      {/if}
      Sign Out
    </Button>
  </div>

  <div class="w-full max-w-5xl space-y-8 animate-fade-in duration-300">
    <!-- Platform Header -->
    <div class="text-center space-y-3">
      <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/5 border border-white/10 text-white/80 backdrop-blur-md">
        <Icon icon="mdi:shield-check-outline" class="text-emerald-400" width="16" />
        <span class="text-[10px] font-extrabold uppercase tracking-widest">Authenticated Session</span>
      </div>
      <h1 class="text-3xl sm:text-5xl font-extrabold font-playfair text-white tracking-tight">
        Cerpsys Management Portal
      </h1>
      <p class="text-sm sm:text-base text-white/70 max-w-lg mx-auto">
        Welcome back, <span class="font-bold text-white">{user?.member?.first_name ?? 'User'} {user?.member?.last_name ?? ''}</span>. 
        Select an application hub below to continue.
      </p>
    </div>

    <!-- App Selector Cards Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-5xl mx-auto">
      <!-- 1. Inventory Hub Card -->
      <a
        href="/dashboard"
        class="group relative block rounded-2xl bg-white/95 dark:bg-slate-900/95 shadow-2xl border border-white/10 overflow-hidden hover:scale-[1.02] hover:-translate-y-1 hover:shadow-emerald-500/10 transition-all duration-300"
      >
        <div class="absolute inset-0 bg-gradient-to-br from-emerald-500/5 to-teal-500/5 opacity-0 group-hover:opacity-100 transition-opacity"></div>
        <div class="p-8 space-y-6 flex flex-col h-full justify-between">
          <div class="space-y-4">
            <!-- Icon container -->
            <div class="h-14 w-14 rounded-2xl bg-teal-500/10 text-teal-600 flex items-center justify-center shadow-inner group-hover:bg-teal-500 group-hover:text-white transition-all duration-300">
              <Icon icon="mdi:warehouse" width="32" height="32" />
            </div>
            <!-- Title & Description -->
            <div class="space-y-2">
              <h2 class="text-2xl font-extrabold font-playfair text-slate-800 dark:text-white group-hover:text-teal-600 transition-colors">
                Inventory Hub
              </h2>
              <p class="text-sm text-slate-600 dark:text-slate-300 leading-relaxed">
                Manage item definitions, track warehouse assets, record stock levels, perform adjustments, customize bins, and run inventory analytics.
              </p>
            </div>
          </div>
          
          <div class="pt-4">
            <span class="inline-flex items-center gap-1.5 text-sm font-bold text-teal-600 group-hover:gap-2.5 transition-all">
              Launch Inventory
              <Icon icon="mdi:arrow-right" width="18" />
            </span>
          </div>
        </div>
      </a>

      <!-- 2. Purchases Hub Card -->
      <a
        href={purchasesUrl}
        class="group relative block rounded-2xl bg-white/95 dark:bg-slate-900/95 shadow-2xl border border-white/10 overflow-hidden hover:scale-[1.02] hover:-translate-y-1 hover:shadow-indigo-500/10 transition-all duration-300"
      >
        <div class="absolute inset-0 bg-gradient-to-br from-indigo-500/5 to-violet-500/5 opacity-0 group-hover:opacity-100 transition-opacity"></div>
        <div class="p-8 space-y-6 flex flex-col h-full justify-between">
          <div class="space-y-4">
            <!-- Icon container -->
            <div class="h-14 w-14 rounded-2xl bg-indigo-500/10 text-indigo-600 flex items-center justify-center shadow-inner group-hover:bg-indigo-500 group-hover:text-white transition-all duration-300">
              <Icon icon="mdi:shopping" width="32" height="32" />
            </div>
            <!-- Title & Description -->
            <div class="space-y-2">
              <h2 class="text-2xl font-extrabold font-playfair text-slate-800 dark:text-white group-hover:text-indigo-600 transition-colors">
                Purchases Hub
              </h2>
              <p class="text-sm text-slate-600 dark:text-slate-300 leading-relaxed">
                Manage vendor details, create purchase orders, confirm incoming for-deliveries, reconcile invoice statements, and post accounts payable payments.
              </p>
            </div>
          </div>
          
          <div class="pt-4">
            <span class="inline-flex items-center gap-1.5 text-sm font-bold text-indigo-600 group-hover:gap-2.5 transition-all">
              Launch Purchases
              <Icon icon="mdi:arrow-right" width="18" />
            </span>
          </div>
        </div>
      </a>

      <!-- 3. POS Hub Card -->
      <a
        href={posUrl}
        class="group relative block rounded-2xl bg-white/95 dark:bg-slate-900/95 shadow-2xl border border-white/10 overflow-hidden hover:scale-[1.02] hover:-translate-y-1 hover:shadow-rose-500/10 transition-all duration-300"
      >
        <div class="absolute inset-0 bg-gradient-to-br from-rose-500/5 to-orange-500/5 opacity-0 group-hover:opacity-100 transition-opacity"></div>
        <div class="p-8 space-y-6 flex flex-col h-full justify-between">
          <div class="space-y-4">
            <!-- Icon container -->
            <div class="h-14 w-14 rounded-2xl bg-rose-500/10 text-rose-600 flex items-center justify-center shadow-inner group-hover:bg-rose-500 group-hover:text-white transition-all duration-300">
              <Icon icon="mdi:cash-register" width="32" height="32" />
            </div>
            <!-- Title & Description -->
            <div class="space-y-2">
              <h2 class="text-2xl font-extrabold font-playfair text-slate-800 dark:text-white group-hover:text-rose-600 transition-colors">
                POS Hub
              </h2>
              <p class="text-sm text-slate-600 dark:text-slate-300 leading-relaxed">
                Process customer sales, manage front sales sessions, track unpaid collections, configure entity terms, services and discounts.
              </p>
            </div>
          </div>
          
          <div class="pt-4">
            <span class="inline-flex items-center gap-1.5 text-sm font-bold text-rose-600 group-hover:gap-2.5 transition-all">
              Launch POS
              <Icon icon="mdi:arrow-right" width="18" />
            </span>
          </div>
        </div>
      </a>
    </div>

    <!-- Active User Footer Badge -->
    <div class="flex items-center justify-center gap-2.5 text-white/50 text-xs">
      <span>Signed in as <span class="text-white/80 font-bold">{user?.member?.email}</span></span>
      <span class="h-1 w-1 bg-white/30 rounded-full"></span>
      <span>Role: <span class="text-white/80 font-bold uppercase">{user?.role?.role_name}</span></span>
    </div>
  </div>
</main>
