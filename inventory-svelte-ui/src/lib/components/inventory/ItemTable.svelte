<script lang="ts">
	import type { InventoryItem } from '$lib/types';
	import * as Table from '$lib/components/ui/table/index.js';
	import Icon from '@iconify/svelte';
	import TableControls from './TableControls.svelte';
	import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';

	let {
		items = [],
		loading = false,
		imageCache = new Map(),
		onloadimage,
		onedit = () => {},
		onview = () => {},
		ondelete = () => {},
		onassign = () => {}
	} = $props<{
		items: InventoryItem[];
		loading?: boolean;
		imageCache?: Map<number, string | null>;
		onloadimage?: (itemId: number) => Promise<string | null>;
		onedit?: (item: InventoryItem) => void;
		onview?: (item: InventoryItem) => void;
		ondelete?: (item: InventoryItem) => void;
		onassign?: (item: InventoryItem) => void;
	}>();

	// Column definitions for customizer
	const columns = [
		{ key: 'image', label: 'Image' },
		{ key: 'category', label: 'Category' },
		{ key: 'description', label: 'Description' },
		{ key: 'stockingUnit', label: 'Stocking Unit' },
		{ key: 'retailUnit', label: 'Retail Unit' },
		{ key: 'wtdAveCost', label: 'Weighted Average Cost' },
		{ key: 'sellingPrice', label: 'Selling Price' }
	];

	let visibleColumns = $state<Record<string, boolean>>({
		image: true,
		category: true,
		description: true,
		stockingUnit: true,
		retailUnit: true,
		wtdAveCost: true,
		sellingPrice: true
	});

	let limit = $state(10);
	let page = $state(1);

	// Derive paginated list
	let paginatedItems = $derived(items.slice((page - 1) * limit, page * limit));

	// Track which item_ids are currently being fetched to avoid duplicate requests
	let fetchingImageIds = new Set<number>();

	// Lazy-load images for currently visible (paginated) items
	$effect(() => {
		if (!onloadimage || !visibleColumns.image) return;
		for (const item of paginatedItems) {
			if (!imageCache.has(item.item_id) && !fetchingImageIds.has(item.item_id)) {
				fetchingImageIds.add(item.item_id);
				onloadimage(item.item_id).finally(() => fetchingImageIds.delete(item.item_id));
			}
		}
	});

	// Reset page when items array changes (e.g. search/filter in parent)
	$effect(() => {
		if (items) {
			page = 1;
		}
	});
</script>

<TableControls {columns} bind:visibleColumns bind:limit bind:page total={items.length}>
	<div class="relative w-full overflow-hidden">
		{#if loading}
			<div class="absolute inset-0 z-20 flex items-center justify-center bg-card/60">
				<div class="flex flex-col items-center gap-2">
					<Icon icon="mdi:loading" class="animate-spin text-primary" width="36" />
					<span class="text-xs font-semibold text-muted-foreground">Loading items...</span>
				</div>
			</div>
		{/if}

		<Table.Root>
			<Table.Header>
				<Table.Row class="border-b border-primary/10 bg-primary/5 hover:bg-primary/5">
					{#if visibleColumns.image !== false}
						<Table.Head class="w-[56px] text-xs font-bold tracking-wider text-foreground/60 uppercase"
							></Table.Head
						>
					{/if}
					{#if visibleColumns.category !== false}
						<Table.Head class="text-xs font-bold tracking-wider text-foreground/60 uppercase"
							>Category</Table.Head
						>
					{/if}
					{#if visibleColumns.description !== false}
						<Table.Head class="text-xs font-bold tracking-wider text-foreground/60 uppercase"
							>Description</Table.Head
						>
					{/if}
					{#if visibleColumns.stockingUnit !== false}
						<Table.Head class="text-xs font-bold tracking-wider text-foreground/60 uppercase"
							>Stk Unit</Table.Head
						>
					{/if}
					{#if visibleColumns.retailUnit !== false}
						<Table.Head class="text-xs font-bold tracking-wider text-foreground/60 uppercase"
							>Retail Unit</Table.Head
						>
					{/if}
					{#if visibleColumns.wtdAveCost !== false}
						<Table.Head
							class="text-right text-xs font-bold tracking-wider text-foreground/60 uppercase"
							>Wtd Ave Cost</Table.Head
						>
					{/if}
					{#if visibleColumns.sellingPrice !== false}
						<Table.Head
							class="text-right text-xs font-bold tracking-wider text-foreground/60 uppercase"
							>Selling Price</Table.Head
						>
					{/if}
					<Table.Head
						class="w-[60px] text-center text-xs font-bold tracking-wider text-foreground/60 uppercase"
					></Table.Head>
				</Table.Row>
			</Table.Header>
			<Table.Body>
				{#if paginatedItems.length === 0}
					<Table.Row>
						<Table.Cell
							colspan={columns.filter((c) => visibleColumns[c.key] !== false).length + 1}
							class="h-40 text-center"
						>
							<div class="flex flex-col items-center gap-2 text-muted-foreground">
								<Icon icon="mdi:package-variant-off" width="36" class="opacity-30" />
								<span class="text-sm">No items found.</span>
							</div>
						</Table.Cell>
					</Table.Row>
				{:else}
					{#each paginatedItems as item, i (item.item_id)}
						<Table.Row
							class="transition-colors hover:bg-primary/5 {i % 2 === 1 ? 'bg-muted/20' : ''}"
						>
							{#if visibleColumns.image !== false}
								<Table.Cell class="w-[56px] p-1.5">
									{@const cachedImage = imageCache.get(item.item_id)}
									{#if cachedImage}
										<div class="w-10 h-10 rounded-lg overflow-hidden border border-border bg-muted/30 flex items-center justify-center">
											<img src={cachedImage} alt={item.model_description} class="w-full h-full object-cover" />
										</div>
									{:else if cachedImage === null}
										<div class="w-10 h-10 rounded-lg border border-border bg-muted/20 flex items-center justify-center">
											<Icon icon="mdi:image-off-outline" width="16" class="text-muted-foreground/40" />
										</div>
									{:else}
										<div class="w-10 h-10 rounded-lg border border-border bg-muted/20 flex items-center justify-center animate-pulse">
											<Icon icon="mdi:image-outline" width="16" class="text-muted-foreground/30" />
										</div>
									{/if}
								</Table.Cell>
							{/if}
							{#if visibleColumns.category !== false}
								<Table.Cell class="text-xs">{item.item_category || '—'}</Table.Cell>
							{/if}
							{#if visibleColumns.description !== false}
								<Table.Cell class="font-medium">
									<div class="font-semibold text-foreground">{item.model_description}</div>
									<div class="mt-1 flex flex-wrap items-center gap-1.5">
										{#if item.brand}
											<span
												class="rounded bg-muted px-1.5 py-0.5 text-[10px] font-normal text-muted-foreground"
												>Brand: {item.brand}</span
											>
										{/if}
										{#if item.barcodes && item.barcodes.length > 0}
											{#each item.barcodes as bc}
												<span
													class="rounded border border-teal-200/50 bg-teal-50 dark:bg-teal-950/40 px-1.5 py-0.5 text-[9px] font-medium tracking-wide text-teal-600 dark:text-teal-400"
													>BC: {bc.barcode_value}</span
												>
											{/each}
										{/if}
									</div>
								</Table.Cell>
							{/if}
							{#if visibleColumns.stockingUnit !== false}
								<Table.Cell class="text-xs">{item.stocking_unit}</Table.Cell>
							{/if}
							{#if visibleColumns.retailUnit !== false}
								<Table.Cell class="text-xs">{item.retail_unit} ({item.rtu_over_stu}x)</Table.Cell>
							{/if}
							{#if visibleColumns.wtdAveCost !== false}
								<Table.Cell class="text-right font-mono text-xs">
									₱{(item.wtd_ave_cost ?? 0).toLocaleString('en-US', {
										minimumFractionDigits: 2,
										maximumFractionDigits: 2
									})}
								</Table.Cell>
							{/if}
							{#if visibleColumns.sellingPrice !== false}
								<Table.Cell class="text-teal-650 text-right font-mono text-xs font-semibold">
									{#if item.selling_price !== null}
										₱{item.selling_price.toLocaleString('en-US', {
											minimumFractionDigits: 2,
											maximumFractionDigits: 2
										})}
									{:else}
										—
									{/if}
								</Table.Cell>
							{/if}
							<Table.Cell class="text-center">
								<DropdownMenu.Root>
									<DropdownMenu.Trigger
										class="rounded-lg p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground focus:outline-none"
									>
										<Icon icon="mdi:dots-vertical" width="17" />
									</DropdownMenu.Trigger>
									<DropdownMenu.Content
										class="bg-card rounded-xl shadow-xl border border-border p-1.5 min-w-44 z-50 mt-1"
										align="end"
									>
										<DropdownMenu.Item
											onclick={() => onview(item)}
											class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors"
										>
											<Icon icon="mdi:eye-outline" width="16" class="text-muted-foreground" />
											View Details
										</DropdownMenu.Item>
										<DropdownMenu.Item
											onclick={() => onedit(item)}
											class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors text-teal-650 dark:text-teal-450 font-medium"
										>
											<Icon icon="mdi:pencil-outline" width="16" />
											Edit Item
										</DropdownMenu.Item>
										{#if !item.in_unit_item}
											<DropdownMenu.Item
												onclick={() => onassign(item)}
												class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors text-emerald-650 dark:text-emerald-450 font-medium"
											>
												<Icon icon="mdi:warehouse" width="16" />
												Assign Location
											</DropdownMenu.Item>
										{/if}
										<DropdownMenu.Separator class="my-1 border-t border-border" />
										<DropdownMenu.Item
											onclick={() => ondelete(item)}
											class="flex items-center gap-2 hover:bg-rose-500/10 text-rose-500 px-3 py-2 rounded-lg cursor-pointer text-sm font-semibold transition-colors"
										>
											<Icon icon="mdi:delete-outline" width="16" />
											Delete Item
										</DropdownMenu.Item>
									</DropdownMenu.Content>
								</DropdownMenu.Root>
							</Table.Cell>
						</Table.Row>
					{/each}
				{/if}
			</Table.Body>
		</Table.Root>
	</div>
</TableControls>
