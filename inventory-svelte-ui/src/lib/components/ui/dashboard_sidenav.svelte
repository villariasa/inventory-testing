<script lang="ts">
  import type { User } from '$lib/types';
  import { page } from '$app/stores';
  import { sidebarCollapsed, mobileSidebarOpen } from '$lib/store/sidebar';
  import Icon from '@iconify/svelte';
  import logo from '$lib/assets/landing/inventory.png';

  let { user }: { user: User } = $props();

  let collapsed = $state(false);
  let mobileOpen = $state(false);

  sidebarCollapsed.subscribe(v => (collapsed = v));
  mobileSidebarOpen.subscribe(v => (mobileOpen = v));

  let currentPath = $derived($page.url.pathname);

  function isActive(url: string): boolean {
    if (url === '/dashboard') return currentPath === '/dashboard';
    return currentPath === url || currentPath.startsWith(url + '/');
  }

  const navItems: any[] = [
    { type: 'item',  id: 'dashboard',      label: 'Dashboard',             icon: 'mdi:view-dashboard-outline',    url: '/dashboard' },
    { type: 'group', name: 'Transaction', items: [
      { id: 'items',          label: 'Item',                 icon: 'mdi:package-variant-closed',    url: '/dashboard/items' },
      { id: 'unit-items',     label: 'Unit Item Tracking',   icon: 'mdi:layers-outline',            url: '/dashboard/unit-items' },
      { id: 'adjustments',    label: 'Adjustment',           icon: 'mdi:swap-horizontal-bold',      url: '/dashboard/adjustments' },
      { id: 'in-transit',     label: 'In-Transit Items',     icon: 'mdi:truck-delivery-outline',    url: '/dashboard/in-transit' }
    ] },
    { type: 'item',  id: 'reports',        label: 'Reports',               icon: 'mdi:chart-bar',                 url: '/dashboard/reports' },
    { type: 'group', name: 'Setting', items: [
      { id: 'item-imports',   label: 'Item Imports',         icon: 'mdi:database-import-outline',   url: '/dashboard/item-imports' },
      { id: 'categories',     label: 'Category',             icon: 'mdi:tag-multiple-outline',      url: '/dashboard/categories' },
      { id: 'units',          label: 'Units',                icon: 'mdi:warehouse',                 url: '/dashboard/units' },
      { id: 'unit-bins',      label: 'Unit Bin',             icon: 'mdi:archive-outline',           url: '/dashboard/unit-bins' },
      { id: 'item-bin-cust',  label: 'Item Bin Customization',icon: 'mdi:swap-horizontal',           url: '/dashboard/item-bin-customization' },
      { id: 'adj-templates',  label: 'Adjustment Templates', icon: 'mdi:file-document-edit-outline',url: '/dashboard/adjustment-templates' }
    ] },
    { type: 'item',  id: 'switch-app',     label: 'Switch Hub',            icon: 'mdi:apps',                      url: '/select-app' }
  ];

  function closeMobile() {
    mobileSidebarOpen.set(false);
    mobileOpen = false;
  }
</script>

<!-- Mobile Backdrop -->
{#if mobileOpen}
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div
    class="fixed inset-0 z-30 bg-black/50 backdrop-blur-sm md:hidden"
    onclick={() => { mobileOpen = false; mobileSidebarOpen.set ? mobileSidebarOpen.set(false) : null; }}
  ></div>
{/if}

<!-- Sidebar -->
<aside
  class="
    fixed top-0 left-0 z-40 h-screen flex flex-col
    bg-gradient-to-b from-teal-dark via-[#1d5952] to-[#163d38]
    transition-all duration-200 ease-in-out
    shadow-2xl shadow-black/30
    {collapsed ? 'w-[64px]' : 'w-[240px]'}
    md:translate-x-0
    {mobileOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'}
  "
>
  <!-- Header: Logo + Toggle -->
  <div class="flex items-center justify-between px-3 pt-6 pb-5 border-b border-white/10 min-h-[76px]">
    {#if !collapsed}
      <div class="flex flex-col pl-1">
        <img src={logo} alt="Serenity" class="h-8 w-auto object-contain" />
        <span class="text-[9px] uppercase tracking-[0.2em] text-white/50 font-bold mt-1 pl-0.5"></span>
      </div>
    {:else}
      <div class="mx-auto">
        <Icon icon="mdi:warehouse" width="26" class="text-white/80" />
      </div>
    {/if}
    <!-- Desktop toggle button -->
    <button
      onclick={() => sidebarCollapsed.toggle()}
      class="hidden md:flex items-center justify-center w-7 h-7 rounded-md text-white/60 hover:text-white hover:bg-white/10 transition-colors ml-auto shrink-0"
      title={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
    >
      <Icon icon={collapsed ? 'mdi:chevron-right' : 'mdi:chevron-left'} width="18" />
    </button>
    <!-- Mobile close button -->
    <button
      onclick={closeMobile}
      class="md:hidden flex items-center justify-center w-7 h-7 rounded-md text-white/60 hover:text-white hover:bg-white/10 transition-colors"
    >
      <Icon icon="mdi:close" width="18" />
    </button>
  </div>

  <!-- Nav Items -->
  <nav class="flex-1 overflow-y-auto overflow-x-hidden py-4 px-2 space-y-3">
    {#each navItems as section, sectionIdx}
      {#if collapsed && sectionIdx > 0}
        <div class="border-t border-white/10 my-2 mx-1.5"></div>
      {/if}

      {#if section.type === 'item'}
        {@const active = isActive(section.url)}
        <div class="space-y-0.5">
          <a
            href={section.url}
            onclick={() => { mobileOpen = false; }}
            title={collapsed ? section.label : undefined}
            class="
              flex items-center gap-3 px-2 py-2 rounded-lg
              transition-all duration-150 group relative
              {active
                ? 'bg-white/15 text-white shadow-sm font-semibold'
                : 'text-white/65 hover:bg-white/10 hover:text-white'}
              {collapsed ? 'justify-center' : ''}
            "
          >
            <!-- Active indicator bar -->
            {#if active}
              <span class="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-mint-light rounded-r-full"></span>
            {/if}

            <Icon
              icon={section.icon}
              width="20"
              class="shrink-0 {active ? 'text-white' : 'text-white/65 group-hover:text-white'}"
            />

            {#if !collapsed}
              <span class="text-sm truncate">{section.label}</span>
            {/if}

            <!-- Tooltip when collapsed -->
            {#if collapsed}
              <div class="
                absolute left-full ml-2 px-2 py-1 rounded-md
                bg-gray-900 text-white text-xs font-semibold whitespace-nowrap
                opacity-0 group-hover:opacity-100 pointer-events-none
                transition-opacity duration-150 z-50
              ">
                {section.label}
              </div>
            {/if}
          </a>
        </div>
      {:else}
        <div class="space-y-0.5">
          {#if !collapsed}
            <div class="text-[10px] font-bold uppercase tracking-[0.15em] text-white/40 px-2.5 mb-1.5 {sectionIdx > 0 ? 'mt-4' : 'mt-1'} select-none">
              {section.name}
            </div>
          {/if}

          {#each section.items as item}
            {@const active = isActive(item.url)}
            <a
              href={item.url}
              onclick={() => { mobileOpen = false; }}
              title={collapsed ? item.label : undefined}
              class="
                flex items-center gap-3 px-2 py-2 rounded-lg
                transition-all duration-150 group relative
                {active
                  ? 'bg-white/15 text-white shadow-sm font-semibold'
                  : 'text-white/65 hover:bg-white/10 hover:text-white'}
                {collapsed ? 'justify-center' : ''}
              "
            >
              <!-- Active indicator bar -->
              {#if active}
                <span class="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-mint-light rounded-r-full"></span>
              {/if}

              <Icon
                icon={item.icon}
                width="20"
                class="shrink-0 {active ? 'text-white' : 'text-white/65 group-hover:text-white'}"
              />

              {#if !collapsed}
                <span class="text-sm truncate">{item.label}</span>
              {/if}

              <!-- Tooltip when collapsed -->
              {#if collapsed}
                <div class="
                  absolute left-full ml-2 px-2 py-1 rounded-md
                  bg-gray-900 text-white text-xs font-semibold whitespace-nowrap
                  opacity-0 group-hover:opacity-100 pointer-events-none
                  transition-opacity duration-150 z-50
                ">
                  {item.label}
                </div>
              {/if}
            </a>
          {/each}
        </div>
      {/if}
    {/each}
  </nav>

  <!-- User info footer -->
  {#if user && !collapsed}
    <div class="border-t border-white/10 px-4 py-3 flex items-center gap-3">
      <div class="w-8 h-8 rounded-full bg-white/20 flex items-center justify-center text-white font-bold text-xs shrink-0">
        {user.member?.first_name?.charAt(0) ?? 'U'}{user.member?.last_name?.charAt(0) ?? ''}
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-white text-xs font-semibold truncate">{user.member?.first_name} {user.member?.last_name}</p>
        <p class="text-white/50 text-[10px] uppercase tracking-wider">{user.role?.role_name ?? 'user'}</p>
      </div>
    </div>
  {:else if user && collapsed}
    <div class="border-t border-white/10 py-3 flex justify-center">
      <div class="w-8 h-8 rounded-full bg-white/20 flex items-center justify-center text-white font-bold text-xs">
        {user.member?.first_name?.charAt(0) ?? 'U'}
      </div>
    </div>
  {/if}
</aside>

<!-- Spacer so content shifts right on desktop -->
<div class="
  hidden md:block shrink-0 transition-all duration-200
  {collapsed ? 'w-[64px]' : 'w-[240px]'}
"></div>