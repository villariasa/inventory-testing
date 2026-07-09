<script lang="ts">
  import * as Card from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import Icon from '@iconify/svelte';

  const reports = [
    {
      id: 'purchases',
      name: 'Purchases Report',
      description: 'Review cost, client data, and purchase history within a custom range.',
      icon: 'mdi:cart',
      color: 'text-teal-dark bg-teal-50 dark:text-teal-400 dark:bg-teal-950/30',
      url: '/dashboard/reports/purchases'
    },
    {
      id: 'stock-card',
      name: 'Stock Card Ledger',
      description: 'Check stock card transactions, movements, and ledger details for a selected unit.',
      icon: 'mdi:card-bulleted',
      color: 'text-emerald-600 bg-emerald-50 dark:text-emerald-400 dark:bg-emerald-950/30',
      url: '/dashboard/reports/stock-card'
    },
    {
      id: 'inventory-list',
      name: 'Inventory List',
      description: 'Get full current stock values and listings across multiple warehouses.',
      icon: 'mdi:format-list-bulleted',
      color: 'text-sky-600 bg-sky-50 dark:text-sky-400 dark:bg-sky-950/30',
      url: '/dashboard/reports/inventory-list'
    },
    {
      id: 'sales',
      name: 'Sales Report',
      description: 'Generate report details for sales orders completed within a specific date range.',
      icon: 'mdi:cash-register',
      color: 'text-indigo-600 bg-indigo-50 dark:text-indigo-400 dark:bg-indigo-950/30',
      url: '/dashboard/reports/sales'
    },
    {
      id: 'deliveries',
      name: 'Deliveries Report',
      description: 'Monitor dispatched and completed deliveries with or without cost values.',
      icon: 'mdi:truck',
      color: 'text-amber-600 bg-amber-50 dark:text-amber-400 dark:bg-amber-950/30',
      url: '/dashboard/reports/deliveries'
    },
    {
      id: 'client-ledger',
      name: 'Client Ledger',
      description: 'Trace specific client account ledger entries and statement histories.',
      icon: 'mdi:book-open',
      color: 'text-violet-600 bg-violet-50 dark:text-violet-400 dark:bg-violet-950/30',
      url: '/dashboard/reports/client-ledger'
    },
    {
      id: 'expiries',
      name: 'Expiries & Past Due',
      description: 'Audit expiring inventory batches, past due stocks, and shelf life details.',
      icon: 'mdi:calendar-alert',
      color: 'text-rose-600 bg-rose-50 dark:text-rose-400 dark:bg-rose-950/30',
      url: '/dashboard/reports/expiries'
    },
    {
      id: 'movements',
      name: 'Internal Movements',
      description: 'Track stock transfers and movement logs internally between unit locations.',
      icon: 'mdi:transfer',
      color: 'text-purple-600 bg-purple-50 dark:text-purple-400 dark:bg-purple-950/30',
      url: '/dashboard/reports/movements'
    }
  ];
</script>

<svelte:head>
  <title>Reports Hub - Serenity Inventory</title>
</svelte:head>

<div class="space-y-6">
  <!-- Page Header -->
  <div>
    <h2 class="text-2xl font-bold font-playfair text-primary">Reports Hub</h2>
    <p class="text-sm text-muted-foreground">Select a report module below to filter, generate, and export data logs.</p>
  </div>

  <!-- Reports Grid -->
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
    {#each reports as r (r.id)}
      <Card.Root class="hover:shadow-md transition-all duration-200 border-border group bg-card">
        <Card.Content class="pt-6">
          <div class="flex items-center gap-4 mb-4">
            <div class="p-3 rounded-xl {r.color}">
              <Icon icon={r.icon} width="24" height="24" />
            </div>
            <Card.Title class="text-base font-bold text-slate-700 dark:text-slate-200">{r.name}</Card.Title>
          </div>
          <Card.Description class="text-xs text-slate-400 dark:text-slate-350 leading-relaxed mb-6 min-h-[36px]">
            {r.description}
          </Card.Description>
          <div class="border-t pt-3 flex justify-end">
            <Button
              variant="link"
              href={r.url}
              class="text-teal-dark hover:text-teal-800 dark:text-teal-400 dark:hover:text-teal-300 text-xs font-semibold p-0 flex items-center gap-1 group-hover:underline"
            >
              Open Report
              <Icon icon="mdi:chevron-right" width="16" />
            </Button>
          </div>
        </Card.Content>
      </Card.Root>
    {/each}
  </div>
</div>
