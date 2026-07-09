<script lang="ts">
  import * as Card from '$lib/components/ui/card/index.js';
  import * as Table from '$lib/components/ui/table/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import Icon from '@iconify/svelte';
  import ChartAreaInteractive from '$lib/components/inventory/ChartAreaInteractive.svelte';

  let { data } = $props<{
    data: {
      stats: {
        totalItems: number;
        totalUnits: number;
        pendingTransit: number;
        totalAdjustments: number;
      };
      recentItems: any[];
      recentAdjustments: any[];
      units: { unit_id: number; description: string }[];
      defaultUnitId: number;
      categoryBreakdown: { label: string; count: number; category_id: number }[];
      chartData: {
        movementPoints: { month: string; value1: number; value2?: number }[];
        adjustmentPoints: { month: string; value1: number; value2?: number }[];
        valuationPoints: { month: string; value1: number }[];
      };
      user: any;
    };
  }>();

  // ─── KPI Cards ────────────────────────────────────────────────────────────────
  const cards = $derived([
    {
      id: 'items',
      title: 'Total Catalog Items',
      value: data.stats.totalItems,
      icon: 'mdi:package-variant',
      color: 'text-teal-dark bg-teal-50 dark:text-teal-400 dark:bg-teal-950/30',
      description: 'Manage part numbers, categories, and prices.',
      url: '/dashboard/items'
    },
    {
      id: 'units',
      title: 'Active Warehouses / Units',
      value: data.stats.totalUnits,
      icon: 'mdi:warehouse',
      color: 'text-emerald-600 bg-emerald-50 dark:text-emerald-400 dark:bg-emerald-950/30',
      description: 'Configure warehouse locations and assignments.',
      url: '/dashboard/units'
    },
    {
      id: 'transit',
      title: 'Pending In-Transit Invoices',
      value: data.stats.pendingTransit,
      icon: 'mdi:truck-delivery',
      color: 'text-amber-600 bg-amber-50 dark:text-amber-400 dark:bg-amber-950/30',
      description: 'Confirm receipts for inbound supplier stocks.',
      url: '/dashboard/in-transit'
    },
    {
      id: 'adjustments',
      title: 'Stock Adjustments (30 Days)',
      value: data.stats.totalAdjustments,
      icon: 'mdi:clipboard-flow',
      color: 'text-rose-600 bg-rose-50 dark:text-rose-400 dark:bg-rose-950/30',
      description: 'Total manual adjustments logged in the last 30 days.',
      url: '/dashboard/adjustments'
    }
  ]);

  // ─── Utility ──────────────────────────────────────────────────────────────────

  /** Format a raw date string from the adjustment SP into a readable date. */
  function formatAdjDate(adj: any): string {
    // frmt_adjustment_date is pre-formatted by the SP if present
    if (adj.frmt_adjustment_date && adj.frmt_adjustment_date !== '—') {
      return adj.frmt_adjustment_date;
    }
    const raw = adj.adjustment_date || adj.added_date;
    if (!raw) return '—';
    const d = new Date(raw);
    if (isNaN(d.getTime())) return String(raw);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  }

  /** Relative time label (e.g. "3 days ago"). */
  function daysAgo(dateStr: string | null | undefined): string {
    if (!dateStr) return '';
    const diff = Date.now() - new Date(dateStr).getTime();
    const days = Math.floor(diff / 86_400_000);
    if (days < 0) return 'Today';
    if (days === 0) return 'Today';
    if (days === 1) return 'Yesterday';
    if (days < 30) return `${days}d ago`;
    if (days < 365) return `${Math.floor(days / 30)}mo ago`;
    return `${Math.floor(days / 365)}y ago`;
  }

  /** Max count across category breakdown for bar scaling. */
  let maxCatCount = $derived(
    data.categoryBreakdown.length > 0
      ? Math.max(...data.categoryBreakdown.map((c: any) => c.count))
      : 1
  );
</script>

<svelte:head>
  <title>Dashboard - Serenity Inventory</title>
</svelte:head>

<div class="space-y-6">
  <!-- ── Welcome Banner ───────────────────────────────────────────────────────── -->
  <div
    class="flex items-center justify-between bg-gradient-to-r from-teal-dark to-green-muted
           text-white p-6 rounded-2xl shadow-sm"
  >
    <div class="space-y-2">
      <h2 class="text-2xl font-bold font-playfair">Welcome to Inventory Management</h2>
      <p class="text-xs text-mint-light/95 font-medium uppercase tracking-wider">
        Inventory Platform • Real-time Operations
      </p>
      <!-- Quick-action shortcuts -->
      <div class="flex items-center gap-2 pt-1 flex-wrap">
        <Button
          href="/dashboard/adjustments"
          size="sm"
          class="h-7 text-xs bg-white/15 hover:bg-white/25 border border-white/30 text-white
                 backdrop-blur-sm transition-all gap-1.5 font-semibold"
        >
          <Icon icon="mdi:plus-circle" width="14" />
          New Adjustment
        </Button>
        <Button
          href="/dashboard/reports"
          size="sm"
          class="h-7 text-xs bg-white/10 hover:bg-white/20 border border-white/20 text-white/90
                 backdrop-blur-sm transition-all gap-1.5 font-semibold"
        >
          <Icon icon="mdi:chart-bar" width="14" />
          View Reports
        </Button>
        <Button
          href="/dashboard/in-transit"
          size="sm"
          class="h-7 text-xs bg-white/10 hover:bg-white/20 border border-white/20 text-white/90
                 backdrop-blur-sm transition-all gap-1.5 font-semibold"
        >
          <Icon icon="mdi:truck-delivery" width="14" />
          In-Transit
        </Button>
      </div>
    </div>
    <div class="opacity-15 hidden md:block">
      <Icon icon="mdi:warehouse" width="80" />
    </div>
  </div>

  <!-- ── KPI Cards ────────────────────────────────────────────────────────────── -->
  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
    {#each cards as card (card.id)}
      <Card.Root class="hover:shadow-md transition-all duration-200 border-border group bg-card">
        <Card.Content class="pt-6">
          <div class="flex items-center justify-between mb-4">
            <div class="p-3 rounded-xl {card.color}">
              <Icon icon={card.icon} width="24" height="24" />
            </div>
            <span class="text-3xl font-mono font-bold text-slate-800 dark:text-slate-100">
              {card.value.toLocaleString()}
            </span>
          </div>
          <Card.Title class="text-base font-bold text-slate-700 dark:text-slate-200">
            {card.title}
          </Card.Title>
          <Card.Description class="text-xs text-slate-400 dark:text-slate-300 mt-2 leading-relaxed">
            {card.description}
          </Card.Description>

          <!-- Category mini-bars (only for Total Items card) -->
          {#if card.id === 'items' && data.categoryBreakdown.length > 0}
            <div class="mt-3 space-y-1.5">
              {#each data.categoryBreakdown as cat}
                <div class="flex items-center gap-2">
                  <span class="text-[9px] text-muted-foreground truncate w-20 shrink-0" title={cat.label}>
                    {cat.label}
                  </span>
                  <div class="flex-1 h-1.5 bg-muted rounded-full overflow-hidden">
                    <div
                      class="h-full rounded-full bg-teal-500/70 transition-all duration-700"
                      style="width: {Math.round((cat.count / maxCatCount) * 100)}%"
                    ></div>
                  </div>
                  <span class="text-[9px] font-mono font-semibold text-muted-foreground w-6 text-right">
                    {cat.count}
                  </span>
                </div>
              {/each}
            </div>
          {/if}

          <Card.Footer class="p-0 border-t pt-3 mt-3 flex justify-end">
            <Button
              variant="link"
              href={card.url}
              class="text-teal-dark hover:text-teal-800 dark:text-teal-400 dark:hover:text-teal-300
                     text-xs font-semibold p-0 flex items-center gap-1 group-hover:underline"
            >
              Manage
              <Icon icon="mdi:arrow-right" width="16" />
            </Button>
          </Card.Footer>
        </Card.Content>
      </Card.Root>
    {/each}
  </div>

  <!-- ── Interactive Chart Section ────────────────────────────────────────────── -->
  <ChartAreaInteractive
    chartData={data.chartData}
    units={data.units}
    defaultUnitId={data.defaultUnitId}
    token={data.user?.access_token ?? ''}
  />

  <!-- ── Summary Tables ────────────────────────────────────────────────────────── -->
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">

    <!-- New Catalog Additions -->
    <div class="bg-card border rounded-2xl shadow-sm overflow-hidden p-5 space-y-4">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <Icon icon="mdi:package-variant-plus" width="20" class="text-primary" />
          <h3 class="font-bold text-foreground font-playfair text-base">New Catalog Additions</h3>
        </div>
        <Button href="/dashboard/items" variant="outline" size="sm" class="text-xs h-8">View All</Button>
      </div>

      <div class="rounded-xl border overflow-hidden">
        <Table.Root>
          <Table.Header class="bg-primary/5">
            <Table.Row>
              <Table.Head class="font-semibold text-xs text-foreground/75">Item Description</Table.Head>
              <Table.Head class="font-semibold text-xs text-foreground/75">Category</Table.Head>
              <Table.Head class="text-right font-semibold text-xs text-foreground/75">Selling Price</Table.Head>
              <Table.Head class="text-right font-semibold text-xs text-foreground/75">Added</Table.Head>
            </Table.Row>
          </Table.Header>
          <Table.Body>
            {#if data.recentItems.length === 0}
              <Table.Row>
                <Table.Cell colspan={4} class="h-28 text-center text-xs text-muted-foreground">
                  No catalog items found.
                </Table.Cell>
              </Table.Row>
            {:else}
              {#each data.recentItems as item}
                <Table.Row class="hover:bg-muted/10 text-xs">
                  <Table.Cell class="font-medium text-foreground">
                    {item.model_description}
                    {#if item.brand_description}
                      <div class="text-[10px] text-muted-foreground font-normal">
                        Brand: {item.brand_description}
                      </div>
                    {/if}
                  </Table.Cell>
                  <Table.Cell>
                    <span
                      class="inline-flex px-1.5 py-0.5 rounded text-[9px] font-semibold uppercase
                             bg-teal-50 text-teal-700 border border-teal-100
                             dark:bg-teal-950/40 dark:text-teal-300 dark:border-teal-900/40"
                    >
                      {item.item_category_description || item.item_category || 'Uncategorized'}
                    </span>
                  </Table.Cell>
                  <Table.Cell class="text-right font-mono font-semibold text-teal-600">
                    {#if item.selling_price != null && item.selling_price !== ''}
                      {@const priceNum = Number(String(item.selling_price).replace(/,/g, ''))}
                      {#if !isNaN(priceNum)}
                        ₱{priceNum.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                      {:else}
                        —
                      {/if}
                    {:else}
                      —
                    {/if}
                  </Table.Cell>
                  <Table.Cell class="text-right whitespace-nowrap">
                    {#if item.datetime_created}
                      <span class="text-[10px] text-muted-foreground">
                        {daysAgo(item.datetime_created)}
                      </span>
                    {:else}
                      <span class="text-muted-foreground">—</span>
                    {/if}
                  </Table.Cell>
                </Table.Row>
              {/each}
            {/if}
          </Table.Body>
        </Table.Root>
      </div>
    </div>

    <!-- Recent Stock Adjustments -->
    <div class="bg-card border rounded-2xl shadow-sm overflow-hidden p-5 space-y-4">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <Icon icon="mdi:swap-horizontal-bold" width="20" class="text-primary" />
          <h3 class="font-bold text-foreground font-playfair text-base">Recent Stock Adjustments</h3>
        </div>
        <Button href="/dashboard/adjustments" variant="outline" size="sm" class="text-xs h-8">
          View All
        </Button>
      </div>

      <div class="rounded-xl border overflow-hidden">
        <Table.Root>
          <Table.Header class="bg-primary/5">
            <Table.Row>
              <Table.Head class="font-semibold text-xs text-foreground/75">Date</Table.Head>
              <Table.Head class="font-semibold text-xs text-foreground/75">Item Description</Table.Head>
              <Table.Head class="text-right font-semibold text-xs text-foreground/75">Qty</Table.Head>
              <Table.Head class="text-center font-semibold text-xs text-foreground/75">Type</Table.Head>
            </Table.Row>
          </Table.Header>
          <Table.Body>
            {#if data.recentAdjustments.length === 0}
              <Table.Row>
                <Table.Cell colspan={4} class="h-28 text-center text-xs text-muted-foreground">
                  No recent adjustments logged.
                </Table.Cell>
              </Table.Row>
            {:else}
              {#each data.recentAdjustments as adj}
                <Table.Row class="hover:bg-muted/10 text-xs">
                  <!-- ✅ Fixed: checks frmt_adjustment_date → adjustment_date → added_date -->
                  <Table.Cell class="whitespace-nowrap text-muted-foreground font-medium">
                    {formatAdjDate(adj)}
                  </Table.Cell>
                  <Table.Cell class="font-medium text-foreground">
                    {adj.item_description || '—'}
                    {#if adj.source_unit || adj.destination_unit}
                      <div class="text-[10px] text-muted-foreground font-normal flex items-center gap-1 mt-0.5">
                        {#if adj.source_unit}
                          <span>{adj.source_unit}</span>
                        {/if}
                        {#if adj.source_unit && adj.destination_unit}
                          <Icon icon="mdi:arrow-right" width="10" />
                        {/if}
                        {#if adj.destination_unit}
                          <span>{adj.destination_unit}</span>
                        {/if}
                      </div>
                    {/if}
                  </Table.Cell>
                  <Table.Cell class="text-right font-mono font-bold text-foreground">
                    {adj.quantity ?? adj.qty ?? 0}
                  </Table.Cell>
                  <Table.Cell class="text-center">
                    <!-- Color-coded by is_addition (pre-computed server-side) -->
                    <span
                      class="inline-flex items-center gap-1 px-1.5 py-0.5 rounded text-[9px]
                             font-bold uppercase border
                             {adj.is_addition
                               ? 'bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-900/40'
                               : 'bg-rose-50 text-rose-700 border-rose-200 dark:bg-rose-950/40 dark:text-rose-300 dark:border-rose-900/40'}"
                    >
                      <Icon
                        icon={adj.is_addition ? 'mdi:arrow-up-bold' : 'mdi:arrow-down-bold'}
                        width="9"
                      />
                      {adj.template_description || adj.template || (adj.is_addition ? 'Stock In' : 'Stock Out')}
                    </span>
                  </Table.Cell>
                </Table.Row>
              {/each}
            {/if}
          </Table.Body>
        </Table.Root>
      </div>
    </div>
  </div>
</div>
