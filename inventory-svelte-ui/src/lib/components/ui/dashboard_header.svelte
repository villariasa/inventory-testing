<script lang="ts">
  import type { User } from '$lib/types';
  import { Button } from "$lib/components/ui/button";
  import { goto } from "$app/navigation";
  import { page } from "$app/stores";
  import Icon from "@iconify/svelte";
  import * as Avatar from "$lib/components/ui/avatar/index.js";
  import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
  import { sidebarCollapsed, mobileSidebarOpen } from '$lib/store/sidebar';
  import { theme } from '$lib/store/theme';
  import { onMount } from 'svelte';
  import { invokeService } from '$lib/service/invokeService';
  import { activeUnit, DEFAULT_UNIT } from '$lib/store/unit';
  import { DEFAULT_USER_ID } from '$lib/store/user';

  let { user }: { user: User } = $props();

  let units = $state<any[]>([]);

  async function loadUnits() {
    const response = await invokeService<any, any>('/get-inventory-unit', {
      body: { bol_getone: 0, unit_id: 0, description: '' },
      token: user?.access_token
    });
    if ('data' in response && response.data.success) {
      units = response.data?.data?.json_data || [];
      if (units.length > 0) {
        await fetchDefaultUserUnit();
      }
    }
  }

  async function fetchDefaultUserUnit() {
    try {
      const response = await invokeService<any, any>('/get-user-designated-unit', {
        body: { user_id: user?.member?.member_id ?? DEFAULT_USER_ID },
        token: user?.access_token
      });
      if ('data' in response && response.data.success) {
        const dataList = response.data?.data?.json_data || [];
        if (dataList.length > 0) {
          activeUnit.set({
            unit_id: dataList[0].unit_id ?? DEFAULT_UNIT.unit_id,
            description: dataList[0].unit ?? dataList[0].description ?? DEFAULT_UNIT.description
          });
          return;
        }
      }
    } catch (e) {
      console.error('Failed to fetch user default unit:', e);
    }
    if (units.length > 0) {
      activeUnit.set({
        unit_id: units[0].unit_id,
        description: units[0].unit ?? units[0].description ?? DEFAULT_UNIT.description
      });
    }
  }

  onMount(() => {
    loadUnits();
  });

  const pageNameMap: Record<string, string> = {
    "/dashboard": "Dashboard",
    "/dashboard/items": "Items Management",
    "/dashboard/categories": "Item Categories",
    "/dashboard/item-imports": "Item Imports",
    "/dashboard/units": "Inventory Units",
    "/dashboard/unit-items": "Unit Items View",
    "/dashboard/adjustments": "Stock Adjustments",
    "/dashboard/adjustment-templates": "Adjustment Templates",
    "/dashboard/in-transit": "In-Transit Invoices",
    "/dashboard/reports": "Reports Hub",
    "/dashboard/reports/purchases": "Purchases Report",
    "/dashboard/reports/stock-card": "Stock Card Report",
    "/dashboard/reports/inventory-list": "Inventory List Report",
    "/dashboard/reports/sales": "Sales Report",
    "/dashboard/reports/deliveries": "Deliveries Report",
    "/dashboard/reports/client-ledger": "Client Ledger",
    "/dashboard/reports/expiries": "Expiries & Past Due",
    "/dashboard/reports/movements": "Internal Stock Movements",
  };

  let pageName = $derived(pageNameMap[$page.url.pathname] ?? "Dashboard");

  const fullName = $derived(
    user?.member
      ? `${user.member.first_name} ${user.member.last_name}`
      : "Guest"
  );

  async function handleLogout() {
    await fetch("/service/auth/logout", { method: "POST" });
    goto("/login");
  }

  function toggleSidebar() {
    // On mobile — open the mobile drawer
    if (window.innerWidth < 768) {
      mobileSidebarOpen.update(v => !v);
    } else {
      sidebarCollapsed.toggle();
    }
  }
</script>

<svelte:head>
  <title>{pageName} — Serenity Inventory</title>
</svelte:head>

<header class="sticky top-0 z-20 flex items-center gap-4 px-5 py-3 bg-card border-b border-border shadow-sm">
  <!-- Hamburger / sidebar toggle -->
  <button
    onclick={toggleSidebar}
    class="flex items-center justify-center w-9 h-9 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors shrink-0"
    title="Toggle sidebar"
  >
    <Icon icon="mdi:menu" width="22" />
  </button>

  <!-- Page title -->
  <p class="font-bold font-playfair tracking-wide text-xl text-primary flex-1 truncate">{pageName}</p>

  <!-- Right actions -->
  <div class="flex items-center gap-1.5">
    <!-- Unit Selector Dropdown -->
    {#if units.length > 0}
      <DropdownMenu.Root>
        <DropdownMenu.Trigger class="focus:outline-none">
          <Button variant="outline" size="sm" class="h-9 px-3 flex items-center gap-1.5 border-border bg-background hover:bg-muted text-foreground font-semibold shadow-sm rounded-lg transition-colors cursor-pointer">
            <Icon icon="mdi:warehouse" width="16" class="text-primary" />
            <span class="max-w-[120px] truncate text-xs">{$activeUnit?.description || 'Loading unit...'}</span>
            <Icon icon="mdi:chevron-down" width="14" class="text-muted-foreground" />
          </Button>
        </DropdownMenu.Trigger>
        <DropdownMenu.Content class="bg-card rounded-xl shadow-xl border border-border p-1.5 min-w-52 max-h-[300px] overflow-y-auto z-50 mt-1" align="end">
          <div class="px-2.5 py-1.5 text-[10px] font-bold text-muted-foreground uppercase tracking-wider border-b border-border mb-1">
            Active Warehouse / Unit
          </div>
          {#each units as u}
            {@const unitDesc = u.unit ?? u.description ?? ''}
            <DropdownMenu.Item
              onclick={() => activeUnit.set({ unit_id: u.unit_id, description: unitDesc })}
              class="flex items-center justify-between hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-xs transition-colors font-medium
                { $activeUnit?.unit_id === u.unit_id ? 'text-primary bg-primary/5 font-bold' : 'text-foreground'}"
            >
              <span class="truncate">{unitDesc}</span>
              {#if $activeUnit?.unit_id === u.unit_id}
                <Icon icon="mdi:check" width="14" class="text-primary" />
              {/if}
            </DropdownMenu.Item>
          {/each}
        </DropdownMenu.Content>
      </DropdownMenu.Root>
    {/if}

    <!-- Theme Toggle -->
    <button
      onclick={() => theme.toggle()}
      class="flex items-center justify-center w-9 h-9 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors"
      title={$theme === 'dark' ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
    >
      {#if $theme === 'dark'}
        <Icon icon="mdi:weather-sunny" width="20" />
      {:else}
        <Icon icon="mdi:weather-night" width="20" />
      {/if}
    </button>

    <!-- Notification Bell -->
    <button class="flex items-center justify-center w-9 h-9 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors">
      <Icon icon="mdi:bell-outline" width="20" />
    </button>

    <!-- User Dropdown -->
    <DropdownMenu.Root>
      <DropdownMenu.Trigger class="focus:outline-none">
        <div class="flex items-center gap-2.5 cursor-pointer group">
          <Avatar.Root class="size-8 rounded-xl">
            <Avatar.Image src={user?.member?.avatar_url} alt={user?.member?.first_name} />
            <Avatar.Fallback class="bg-primary text-white font-bold text-xs flex items-center justify-center rounded-xl size-8">
              {#if user?.member}
                {user.member.first_name.charAt(0)}{user.member.last_name.charAt(0)}
              {:else}
                G
              {/if}
            </Avatar.Fallback>
          </Avatar.Root>
          <div class="hidden sm:flex flex-col text-left">
            <span class="font-semibold text-sm text-foreground leading-none">{fullName}</span>
            <span class="text-[10px] text-muted-foreground uppercase tracking-wider mt-0.5">
              {user?.role?.role_name ?? "guest"}
            </span>
          </div>
          <Icon icon="mdi:chevron-down" width="16" class="text-muted-foreground group-hover:text-foreground transition-colors hidden sm:block" />
        </div>
      </DropdownMenu.Trigger>

      <DropdownMenu.Content class="bg-card rounded-xl shadow-xl border border-border p-1.5 min-w-44 z-50 mt-1">
        <DropdownMenu.Item onclick={() => goto("/dashboard/profile")} class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors">
          <Icon icon="mdi:account-outline" width="16" class="text-muted-foreground" />
          My Profile
        </DropdownMenu.Item>
        <DropdownMenu.Item onclick={() => goto("/settings")} class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors">
          <Icon icon="mdi:cog-outline" width="16" class="text-muted-foreground" />
          Settings
        </DropdownMenu.Item>
        <DropdownMenu.Separator class="my-1 border-t border-border" />
        <DropdownMenu.Item onclick={handleLogout} class="flex items-center gap-2 hover:bg-destructive/10 text-destructive px-3 py-2 rounded-lg cursor-pointer text-sm font-semibold transition-colors">
          <Icon icon="mdi:logout" width="16" />
          Logout
        </DropdownMenu.Item>
      </DropdownMenu.Content>
    </DropdownMenu.Root>
  </div>
</header>
