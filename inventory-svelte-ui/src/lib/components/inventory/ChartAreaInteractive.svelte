<script lang="ts">
  import Icon from '@iconify/svelte';
  import { fade } from 'svelte/transition';
  import { invokeService } from '$lib/service/invokeService';

  type DataPoint = {
    month: string;
    value1: number;
    value2?: number;
  };

  interface ChartData {
    movementPoints: DataPoint[];
    adjustmentPoints: DataPoint[];
    valuationPoints: { month: string; value1: number }[];
  }

  interface InventoryUnit {
    unit_id: number;
    description: string;
  }

  let {
    chartData,
    units = [],
    defaultUnitId = 0,
    token = ''
  }: {
    chartData: ChartData;
    units: InventoryUnit[];
    defaultUnitId: number;
    token?: string;
  } = $props();

  // $derived directly from props — server data is available immediately on first paint.
  // movementOverride is only mutated by the unit selector client-side.
  let baseMovement = $derived(chartData?.movementPoints ?? []);
  let baseAdjustments = $derived(chartData?.adjustmentPoints ?? []);
  let baseValuation = $derived(chartData?.valuationPoints ?? []);

  let movementOverride = $state<DataPoint[] | null>(null);
  let loadingChart = $state(false);
  let selectedUnitId = $state(defaultUnitId);

  // When base movement prop changes (navigation), clear client-side override
  $effect(() => {
    void baseMovement;
    movementOverride = null;
    selectedUnitId = defaultUnitId;
  });

  let movementPoints = $derived(movementOverride ?? baseMovement);

  type MetricKey = 'movement' | 'adjustments' | 'valuation';
  let activeMetricKey = $state<MetricKey>('movement');

  const METRIC_META = {
    movement: {
      title: 'Stock Movements',
      desc: 'Monthly stock-in vs. stock-out from the stock card ledger.',
      label1: 'Stock In',
      label2: 'Stock Out',
      lineColor1: '#10b981',
      lineColor2: '#f59e0b',
      gradColor1: '#10b981',
      gradColor2: '#f59e0b'
    },
    adjustments: {
      title: 'Inventory Adjustments',
      desc: 'Monthly count of manual stock additions vs. subtractions.',
      label1: 'Additions',
      label2: 'Subtractions',
      lineColor1: '#0d9488',
      lineColor2: '#e11d48',
      gradColor1: '#0d9488',
      gradColor2: '#e11d48'
    },
    valuation: {
      title: 'Asset Valuation by Unit',
      desc: 'Current total stock value per warehouse or unit (snapshot).',
      label1: 'Total Value',
      label2: undefined,
      lineColor1: '#4f46e5',
      lineColor2: undefined,
      gradColor1: '#4f46e5',
      gradColor2: undefined
    }
  } as const;

  let meta = $derived(METRIC_META[activeMetricKey]);

  let activePoints = $derived<DataPoint[]>(
    activeMetricKey === 'movement'
      ? movementPoints
      : activeMetricKey === 'adjustments'
        ? baseAdjustments
        : baseValuation
  );

  let isEmpty = $derived(activePoints.length === 0);

  const width = 600;
  const height = 240;
  const pL = 62;
  const pR = 20;
  const pT = 20;
  const pB = 44;

  let maxVal = $derived(
    Math.max(...activePoints.flatMap((p) => [p.value1, p.value2 ?? 0]), 1) * 1.15
  );

  function getX(i: number, total: number): number {
    const cw = width - pL - pR;
    return total <= 1 ? pL + cw / 2 : pL + (i / (total - 1)) * cw;
  }

  function getY(value: number): number {
    const ch = height - pT - pB;
    return height - pB - (value / maxVal) * ch;
  }

  const maxBarWidth = 56;
  function getBarX(i: number, total: number): number {
    const cw = width - pL - pR;
    const bw = Math.min((cw / Math.max(total, 1)) * 0.65, maxBarWidth);
    const step = cw / Math.max(total, 1);
    return pL + step * i + (step - bw) / 2;
  }
  function getBarW(total: number): number {
    const cw = width - pL - pR;
    return Math.min((cw / Math.max(total, 1)) * 0.65, maxBarWidth);
  }
  function getBarH(value: number): number {
    const ch = height - pT - pB;
    return (value / maxVal) * ch;
  }

  let path1 = $derived.by(() => {
    if (activeMetricKey === 'valuation' || activePoints.length === 0) return '';
    return activePoints
      .map((p, i) => `${i === 0 ? 'M' : 'L'} ${getX(i, activePoints.length)} ${getY(p.value1)}`)
      .join(' ');
  });

  let area1 = $derived.by(() => {
    if (activeMetricKey === 'valuation' || activePoints.length === 0) return '';
    const x0 = getX(0, activePoints.length);
    const xN = getX(activePoints.length - 1, activePoints.length);
    const base = height - pB;
    return `${path1} L ${xN} ${base} L ${x0} ${base} Z`;
  });

  let path2 = $derived.by(() => {
    if (activeMetricKey === 'valuation' || !activePoints.some((p) => 'value2' in p)) return '';
    return activePoints
      .map((p, i) => `${i === 0 ? 'M' : 'L'} ${getX(i, activePoints.length)} ${getY(p.value2!)}`)
      .join(' ');
  });

  let area2 = $derived.by(() => {
    if (
      activeMetricKey === 'valuation' ||
      !activePoints.some((p) => 'value2' in p) ||
      activePoints.length === 0
    )
      return '';
    const x0 = getX(0, activePoints.length);
    const xN = getX(activePoints.length - 1, activePoints.length);
    const base = height - pB;
    return `${path2} L ${xN} ${base} L ${x0} ${base} Z`;
  });

  let hoverIndex = $state<number | null>(null);
  let tipX = $state(0);
  let tipY = $state(0);

  function handleMouseMove(e: MouseEvent) {
    if (isEmpty) return;
    const svg = e.currentTarget as SVGSVGElement;
    const rect = svg.getBoundingClientRect();
    const vbX = ((e.clientX - rect.left) / rect.width) * width;
    const cw = width - pL - pR;
    const frac = (vbX - pL) / cw;
    let idx = Math.round(frac * (activePoints.length - 1));
    idx = Math.max(0, Math.min(activePoints.length - 1, idx));
    hoverIndex = idx;
    tipX =
      activeMetricKey === 'valuation'
        ? getBarX(idx, activePoints.length) + getBarW(activePoints.length) / 2
        : getX(idx, activePoints.length);
    const pt = activePoints[idx];
    tipY = getY(Math.max(pt.value1, pt.value2 ?? 0)) - 14;
  }

  function handleMouseLeave() {
    hoverIndex = null;
  }

  function fmt(val: number): string {
    if (activeMetricKey === 'valuation') {
      if (val >= 1_000_000) return `P${(val / 1_000_000).toFixed(1)}M`;
      if (val >= 1_000) return `P${(val / 1_000).toFixed(0)}k`;
      return `P${val.toLocaleString()}`;
    }
    if (val >= 1_000) return `${(val / 1_000).toFixed(1)}k`;
    return val.toLocaleString();
  }

  function fmtY(val: number): string {
    if (activeMetricKey === 'valuation') {
      if (val >= 1_000_000) return `P${(val / 1_000_000).toFixed(1)}M`;
      if (val >= 1_000) return `P${Math.round(val / 1_000)}k`;
      return `P${Math.round(val)}`;
    }
    if (val >= 1_000) return `${Math.round(val / 1_000)}k`;
    return Math.round(val).toString();
  }

  function truncateLabel(str: string, max = 8): string {
    return str.length > max ? str.slice(0, max) + '...' : str;
  }

  let total1 = $derived(activePoints.reduce((s, p) => s + p.value1, 0));
  let total2 = $derived(activePoints.reduce((s, p) => s + (p.value2 ?? 0), 0));

  let trendPct = $derived.by(() => {
    if (activePoints.length < 2) return 0;
    const first = activePoints[0].value1;
    const last = activePoints[activePoints.length - 1].value1;
    if (first === 0) return 0;
    return ((last - first) / first) * 100;
  });

  let gridLines = $derived(
    [0, 1, 2, 3].map((i) => {
      const frac = i / 3;
      const yVal = pT + frac * (height - pT - pB);
      const dataVal = maxVal - frac * maxVal;
      return { yVal, dataVal };
    })
  );

  // Selected unit label for display
  let selectedUnitLabel = $derived(
    selectedUnitId === 0
      ? 'All Units'
      : (units.find((u) => u.unit_id === selectedUnitId)?.description ?? `Unit #${selectedUnitId}`)
  );

  async function handleUnitChange(e: Event) {
    const newId = Number((e.target as HTMLSelectElement).value);
    selectedUnitId = newId;
    if (activeMetricKey !== 'movement') return;
    await refreshMovementChart(newId);
  }

  // Uses same endpoint + key format as the server (stock card, "Mmm YYYY" keys)
  async function refreshMovementChart(unitId: number) {
    loadingChart = true;
    hoverIndex = null;

    const today = new Date();
    const sixAgo = new Date();
    sixAgo.setMonth(sixAgo.getMonth() - 6);
    const start = sixAgo.toISOString().split('T')[0];
    const end = today.toISOString().split('T')[0];

    const res = await invokeService<any, any[]>('/get-stock-card', {
      body: { unit_id: unitId, start_date: start, end_date: end },
      token
    });

    if ('data' in res && res.data.success) {
      const rows: any[] = res.data?.data?.json_data || [];

      // Zero-fill 6-month buckets using same "Mmm YYYY" key as the server
      const byMonth = new Map<string, { value1: number; value2: number; sortKey: number }>();
      const cursor = new Date(sixAgo.getFullYear(), sixAgo.getMonth(), 1);
      while (cursor <= today) {
        const key =
          cursor.toLocaleDateString('en-US', { month: 'short' }) + ' ' + cursor.getFullYear();
        byMonth.set(key, { value1: 0, value2: 0, sortKey: cursor.getTime() });
        cursor.setMonth(cursor.getMonth() + 1);
      }

      for (const row of rows) {
        if (!row.entry_date || String(row.reference ?? '').toUpperCase() === 'QTYFWD') continue;
        const parts = String(row.entry_date).trim().split(/\s+/);
        if (parts.length < 2) continue;
        const [year, mon] = [parts[0], parts[1]];
        const key = `${mon} ${year}`; // "Jun 2026"
        if (!byMonth.has(key)) continue;
        const itemIn = parseFloat(String(row.item_in ?? '0').replace(/,/g, ''));
        const itemOut = parseFloat(String(row.item_out ?? '0').replace(/,/g, ''));
        const bucket = byMonth.get(key)!;
        if (!isNaN(itemIn)) bucket.value1 += itemIn;
        if (!isNaN(itemOut)) bucket.value2 += itemOut;
      }

      movementOverride = [...byMonth.entries()]
        .sort((a, b) => a[1].sortKey - b[1].sortKey)
        .map(([month, v]) => ({ month, value1: v.value1, value2: v.value2 }));
    } else {
      movementOverride = null;
      console.error('[Chart] Stock card refresh failed:', res);
    }
    loadingChart = false;
  }

  function handleTabChange(key: MetricKey) {
    hoverIndex = null;
    activeMetricKey = key;
  }
</script>

<div class="bg-card border rounded-2xl shadow-sm overflow-hidden">
  <!-- Header -->
  <div
    class="flex flex-col md:flex-row md:items-center justify-between gap-4 p-5 border-b border-border bg-primary/5"
  >
    <div class="space-y-1">
      <div class="flex items-center gap-2">
        <div class="p-1.5 rounded-lg bg-primary/10 text-primary">
          <Icon icon="mdi:chart-areaspline-variant" width="18" />
        </div>
        <h3 class="font-bold text-foreground font-playfair text-base">{meta.title}</h3>
        {#if loadingChart}
          <span class="inline-flex items-center gap-1 text-[10px] text-muted-foreground animate-pulse">
            <Icon icon="mdi:loading" width="12" class="animate-spin" />
            Refreshing...
          </span>
        {/if}
      </div>
      <p class="text-xs text-muted-foreground">{meta.desc}</p>
    </div>

    <div class="flex items-center gap-2 flex-wrap self-start md:self-auto">
      <!-- Styled unit selector — only on Movements tab -->
      {#if activeMetricKey === 'movement' && units.length > 0}
        <div class="unit-select-wrapper" transition:fade={{ duration: 150 }}>
          <span class="unit-select-icon">
            <Icon icon="mdi:warehouse" width="13" />
          </span>
          <select
            value={selectedUnitId}
            onchange={handleUnitChange}
            class="unit-select"
            title="Filter by warehouse unit"
          >
            <option value={0}>All Units</option>
            {#each units as u}
              <option value={u.unit_id}>{u.description}</option>
            {/each}
          </select>
          <span class="unit-select-chevron">
            <Icon icon="mdi:chevron-down" width="14" />
          </span>
        </div>
      {/if}

      <!-- Metric tabs -->
      <div class="flex p-1 bg-muted rounded-xl border">
        {#each (['movement', 'adjustments', 'valuation'] as MetricKey[]) as key}
          <button
            onclick={() => handleTabChange(key)}
            class="px-3 py-1.5 text-xs font-semibold rounded-lg transition-all
              {activeMetricKey === key
                ? 'bg-background text-primary shadow-sm'
                : 'text-muted-foreground hover:text-foreground'}"
          >
            {key === 'movement' ? 'Movements' : key === 'adjustments' ? 'Adjustments' : 'Valuation'}
          </button>
        {/each}
      </div>
    </div>
  </div>

  <div class="p-5 flex flex-col md:flex-row gap-6">
    <!-- Chart area -->
    <div class="flex-1 relative max-w-3xl w-full mx-auto">
      {#if isEmpty && !loadingChart}
        <div class="flex flex-col items-center justify-center h-[240px] gap-3 text-muted-foreground">
          <Icon icon="mdi:chart-timeline-variant-shimmer" width="40" class="opacity-25" />
          <div class="text-center">
            <p class="text-sm font-semibold text-foreground/60">No data available</p>
            <p class="text-xs text-muted-foreground mt-0.5">
              No ledger records found for this period.
            </p>
          </div>
        </div>
      {:else}
        {#if loadingChart}
          <div
            class="absolute inset-0 z-10 flex items-center justify-center bg-background/70 backdrop-blur-sm rounded-xl"
            transition:fade={{ duration: 150 }}
          >
            <div class="flex flex-col items-center gap-2 text-muted-foreground">
              <Icon icon="mdi:loading" width="28" class="animate-spin text-primary" />
              <span class="text-xs font-medium">Loading chart data...</span>
            </div>
          </div>
        {/if}

        <svg
          width={width}
          height={height}
          viewBox="0 0 {width} {height}"
          class="w-full h-auto overflow-visible select-none"
          onmousemove={handleMouseMove}
          onmouseleave={handleMouseLeave}
        >
          <defs>
            <linearGradient id="inv-grad1" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color={meta.gradColor1} stop-opacity="0.28" />
              <stop offset="100%" stop-color={meta.gradColor1} stop-opacity="0.01" />
            </linearGradient>
            {#if meta.gradColor2}
              <linearGradient id="inv-grad2" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stop-color={meta.gradColor2} stop-opacity="0.22" />
                <stop offset="100%" stop-color={meta.gradColor2} stop-opacity="0.01" />
              </linearGradient>
            {/if}
            <linearGradient id="inv-bar-grad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color={meta.gradColor1} stop-opacity="0.9" />
              <stop offset="100%" stop-color={meta.gradColor1} stop-opacity="0.5" />
            </linearGradient>
          </defs>

          <!-- Gridlines + Y-axis labels -->
          {#each gridLines as gl}
            <line
              x1={pL}
              y1={gl.yVal}
              x2={width - pR}
              y2={gl.yVal}
              stroke="currentColor"
              stroke-opacity="0.08"
              stroke-width="1"
              stroke-dasharray="4 3"
            />
            <text
              x={pL - 6}
              y={gl.yVal + 4}
              text-anchor="end"
              font-size="10"
              fill="currentColor"
              fill-opacity="0.45"
              font-family="monospace"
            >
              {fmtY(gl.dataVal)}
            </text>
          {/each}

          <!-- AREA CHART: movement & adjustments -->
          {#if activeMetricKey !== 'valuation'}
            {#if area2}
              <path d={area2} fill="url(#inv-grad2)" />
            {/if}
            <path d={area1} fill="url(#inv-grad1)" />

            {#if path2}
              <path
                d={path2}
                fill="none"
                stroke={meta.lineColor2}
                stroke-width="2.5"
                stroke-linecap="round"
                stroke-linejoin="round"
              />
            {/if}
            <path
              d={path1}
              fill="none"
              stroke={meta.lineColor1}
              stroke-width="2.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            />

            <!-- X-axis labels -->
            {#each activePoints as pt, i}
              <text
                x={getX(i, activePoints.length)}
                y={height - pB + 16}
                text-anchor="middle"
                font-size="10"
                font-weight="600"
                fill="currentColor"
                fill-opacity="0.45"
              >
                {pt.month}
              </text>
            {/each}

            <!-- Hover guideline + dots -->
            {#if hoverIndex !== null}
              <line
                x1={getX(hoverIndex, activePoints.length)}
                y1={pT}
                x2={getX(hoverIndex, activePoints.length)}
                y2={height - pB}
                stroke={meta.lineColor1}
                stroke-opacity="0.3"
                stroke-width="1.5"
                stroke-dasharray="3 2"
              />
              <circle
                cx={getX(hoverIndex, activePoints.length)}
                cy={getY(activePoints[hoverIndex].value1)}
                r="5"
                fill={meta.lineColor1}
                stroke="white"
                stroke-width="1.5"
              />
              {#if activePoints[hoverIndex].value2 !== undefined}
                <circle
                  cx={getX(hoverIndex, activePoints.length)}
                  cy={getY(activePoints[hoverIndex].value2!)}
                  r="5"
                  fill={meta.lineColor2}
                  stroke="white"
                  stroke-width="1.5"
                />
              {/if}
            {/if}
          {:else}
            <!-- BAR CHART: valuation per-unit -->
            {#each activePoints as pt, i}
              {@const bx = getBarX(i, activePoints.length)}
              {@const bw = getBarW(activePoints.length)}
              {@const bh = getBarH(pt.value1)}
              {@const by_ = height - pB - bh}
              <rect
                x={bx}
                y={pT}
                width={bw}
                height={height - pT - pB}
                rx="4"
                fill="currentColor"
                fill-opacity="0.05"
              />
              <rect
                x={bx}
                y={by_}
                width={bw}
                height={bh}
                rx="4"
                fill={hoverIndex === i ? meta.gradColor1 : 'url(#inv-bar-grad)'}
                opacity={hoverIndex === i ? '1' : '0.82'}
              />
              <text
                x={bx + bw / 2}
                y={height - pB + 14}
                text-anchor="middle"
                font-size="9"
                font-weight="600"
                fill="currentColor"
                fill-opacity="0.45"
              >
                {truncateLabel(pt.month, Math.max(6, Math.floor(bw / 6)))}
              </text>
            {/each}
            {#if hoverIndex !== null}
              <rect
                x={getBarX(hoverIndex, activePoints.length) - 1}
                y={pT - 2}
                width={getBarW(activePoints.length) + 2}
                height={height - pT - pB + 4}
                rx="5"
                fill="none"
                stroke={meta.lineColor1}
                stroke-width="1.5"
                stroke-opacity="0.5"
              />
            {/if}
          {/if}
        </svg>

        <!-- Tooltip -->
        {#if hoverIndex !== null && !isEmpty}
          {@const pt = activePoints[hoverIndex]}
          <div
            class="absolute z-20 bg-card border border-border shadow-xl rounded-xl p-3 text-xs space-y-1.5 pointer-events-none min-w-[130px]"
            style="left:{(tipX / width) * 100}%; top:{(tipY / height) * 100}%; transform:translate(-50%,-100%);"
            transition:fade={{ duration: 60 }}
          >
            <div class="font-bold text-foreground truncate max-w-[160px]">
              {activeMetricKey === 'valuation' ? pt.month : `${pt.month}`}
            </div>
            <div class="space-y-1">
              <div class="flex items-center justify-between gap-4">
                <span class="flex items-center gap-1.5 text-muted-foreground font-semibold">
                  <span class="w-2 h-2 rounded-full shrink-0" style="background:{meta.lineColor1}"></span>
                  {meta.label1}
                </span>
                <span class="font-mono font-bold text-foreground">{fmt(pt.value1)}</span>
              </div>
              {#if pt.value2 !== undefined && meta.label2}
                <div class="flex items-center justify-between gap-4">
                  <span class="flex items-center gap-1.5 text-muted-foreground font-semibold">
                    <span class="w-2 h-2 rounded-full shrink-0" style="background:{meta.lineColor2}"></span>
                    {meta.label2}
                  </span>
                  <span class="font-mono font-bold text-foreground">{fmt(pt.value2)}</span>
                </div>
              {/if}
            </div>
          </div>
        {/if}
      {/if}
    </div>

    <!-- Summary sidebar -->
    <div
      class="w-full md:w-52 border-t md:border-t-0 md:border-l border-border pt-5 md:pt-0 md:pl-6 flex flex-row md:flex-col justify-around md:justify-center gap-6"
    >
      <div class="space-y-1">
        <p class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">
          {meta.label1} Total
        </p>
        <p class="text-2xl font-bold font-mono text-foreground">{fmt(total1)}</p>
        {#if activePoints.length >= 2}
          <span
            class="inline-flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-full border
              {trendPct >= 0
                ? 'text-emerald-600 bg-emerald-50 dark:bg-emerald-950/20 border-emerald-100 dark:border-emerald-900/30'
                : 'text-rose-600 bg-rose-50 dark:bg-rose-950/20 border-rose-100 dark:border-rose-900/30'}"
          >
            <Icon icon={trendPct >= 0 ? 'mdi:trending-up' : 'mdi:trending-down'} width="11" />
            {trendPct >= 0 ? '+' : ''}{trendPct.toFixed(1)}%
          </span>
        {/if}
      </div>

      {#if meta.label2}
        <div class="space-y-1">
          <p class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">
            {meta.label2} Total
          </p>
          <p class="text-2xl font-bold font-mono text-foreground">{fmt(total2)}</p>
          {#if activePoints.length >= 2}
            {@const trend2 = (() => {
              const first = activePoints[0].value2 ?? 0;
              const last = activePoints[activePoints.length - 1].value2 ?? 0;
              return first === 0 ? 0 : ((last - first) / first) * 100;
            })()}
            <span
              class="inline-flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-full border
                {trend2 >= 0
                  ? 'text-emerald-600 bg-emerald-50 dark:bg-emerald-950/20 border-emerald-100 dark:border-emerald-900/30'
                  : 'text-rose-600 bg-rose-50 dark:bg-rose-950/20 border-rose-100 dark:border-rose-900/30'}"
            >
              <Icon icon={trend2 >= 0 ? 'mdi:trending-up' : 'mdi:trending-down'} width="11" />
              {trend2 >= 0 ? '+' : ''}{trend2.toFixed(1)}%
            </span>
          {/if}
        </div>
      {/if}

      <div class="hidden md:block space-y-0.5 mt-auto pt-4 border-t border-border">
        <p class="text-[10px] text-muted-foreground font-medium">
          {activeMetricKey === 'valuation' ? 'Current snapshot' : 'Last 6 months'}
        </p>
        {#if activeMetricKey === 'movement' && units.length > 0}
          <p class="text-[10px] text-muted-foreground">
            Unit: <span class="font-semibold text-foreground">{selectedUnitLabel}</span>
          </p>
        {/if}
        <p class="text-[10px] text-muted-foreground">
          Source:
          <span class="font-semibold text-foreground">
            {activeMetricKey === 'movement'
              ? 'Stock Card Ledger'
              : activeMetricKey === 'adjustments'
                ? 'Adjustments Log'
                : 'Inventory List'}
          </span>
        </p>
      </div>
    </div>
  </div>
</div>

<style>
  /* Custom unit dropdown — no browser defaults, fully styled */
  .unit-select-wrapper {
    position: relative;
    display: inline-flex;
    align-items: center;
  }

  .unit-select {
    height: 2rem;                /* 32px */
    padding: 0 2rem 0 2rem;      /* space for left icon + right chevron */
    font-size: 0.75rem;          /* text-xs */
    font-weight: 600;
    border-radius: 0.5rem;       /* rounded-lg */
    border: 1.5px solid hsl(var(--border));
    background-color: hsl(var(--card));
    color: hsl(var(--foreground));
    cursor: pointer;
    outline: none;
    appearance: none;
    -webkit-appearance: none;
    -moz-appearance: none;
    transition:
      border-color 0.15s ease,
      box-shadow 0.15s ease,
      background-color 0.15s ease;
    min-width: 130px;
  }

  .unit-select:hover {
    border-color: hsl(var(--primary) / 0.5);
    background-color: hsl(var(--muted) / 0.4);
  }

  .unit-select:focus {
    border-color: hsl(var(--primary) / 0.7);
    box-shadow: 0 0 0 3px hsl(var(--primary) / 0.12);
  }

  /* Left warehouse icon */
  .unit-select-icon {
    position: absolute;
    left: 0.5rem;
    top: 50%;
    transform: translateY(-50%);
    pointer-events: none;
    display: flex;
    align-items: center;
    color: hsl(var(--primary));
    z-index: 1;
  }

  /* Right chevron icon */
  .unit-select-chevron {
    position: absolute;
    right: 0.5rem;
    top: 50%;
    transform: translateY(-50%);
    pointer-events: none;
    display: flex;
    align-items: center;
    color: hsl(var(--muted-foreground));
    z-index: 1;
    transition: transform 0.15s ease;
  }

  .unit-select-wrapper:focus-within .unit-select-chevron {
    transform: translateY(-50%) rotate(180deg);
    color: hsl(var(--primary));
  }
</style>
