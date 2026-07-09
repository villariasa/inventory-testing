<script lang="ts">
	import type { PageData } from './$types';
	import type { ItemCategory } from '$lib/types';
	import { invokeService } from '$lib/service/invokeService';
	import { invalidateAll } from '$app/navigation';
	import { toast } from 'svelte-sonner';
	import StatusBadge from '$lib/components/inventory/StatusBadge.svelte';
	import SearchCombobox from '$lib/components/ui/SearchCombobox.svelte';
	import { Button } from '$lib/components/ui/button/index.js';
	import { Input } from '$lib/components/ui/input/index.js';
	import { Label } from '$lib/components/ui/label/index.js';
	import * as Table from '$lib/components/ui/table/index.js';
	import * as Dialog from '$lib/components/ui/dialog/index.js';
	import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
	import Icon from '@iconify/svelte';
	import TableControls from '$lib/components/inventory/TableControls.svelte';

	let { data } = $props<{
		data: PageData & {
			categories: any[];
			glslAccounts: { glsl_id: number; account: string }[];
			user: any;
		};
	}>();

	let searchQuery = $state('');

	// Normalize category description access
	let normalizedCategories = $derived(
		data.categories.map((c: any) => ({
			item_category_id: c.item_category_id,
			item_category_description: c.item_category_description ?? c.description ?? '',
			status: c.status ?? 'ACTIVE',
			glsl_id: c.glsl_id ?? null,
			glsl_item_elab: c.glsl_item_elab ?? 'No Account Linked'
		}))
	);

	let filteredCategories = $derived(
		normalizedCategories.filter((c: any) =>
			c.item_category_description.toLowerCase().includes(searchQuery.toLowerCase())
		)
	);

	// Form dialog states
	let formOpen = $state(false);
	let selectedCategory = $state<any | null>(null);
	let categoryDescription = $state('');
	let glslId = $state<number | null>(null);

	// Table controls state
	const columns = [
		{ key: 'name', label: 'Category Name' },
		{ key: 'status', label: 'Status' }
	];

	let visibleColumns = $state<Record<string, boolean>>({
		name: true,
		status: true
	});

	let limit = $state(10);
	let page = $state(1);

	let paginatedCategories = $derived(filteredCategories.slice((page - 1) * limit, page * limit));

	$effect(() => {
		if (filteredCategories) {
			page = 1;
		}
	});

	// Delete states
	let deleteOpen = $state(false);
	let selectedCategoryForDelete = $state<any | null>(null);

	$effect(() => {
		if (formOpen) {
			if (selectedCategory) {
				categoryDescription = selectedCategory.item_category_description;
				glslId = selectedCategory.glsl_id;
			} else {
				categoryDescription = '';
				glslId = null;
			}
		}
	});

	function openAdd() {
		selectedCategory = null;
		formOpen = true;
	}

	function openEdit(cat: any) {
		selectedCategory = cat;
		formOpen = true;
	}

	function openDelete(cat: any) {
		selectedCategoryForDelete = cat;
		deleteOpen = true;
	}

	async function submitForm(e: Event) {
		e.preventDefault();
		if (!categoryDescription.trim()) return;

		const isEdit = !!selectedCategory;
		const process_type = isEdit ? 1 : 0;
		const toastId = toast.loading(isEdit ? 'Updating category...' : 'Creating category...');

		const response = await invokeService<any, any>('/post-inventory-item-category', {
			body: {
				process_type,
				item_category_id: isEdit ? selectedCategory.item_category_id : 0,
				description: categoryDescription,
				glsl_id: glslId,
				user_id: data.user.member?.member_id ?? 1
			},
			token: data.user.access_token
		});

		formOpen = false;

		if ('data' in response && response.data.success) {
			toast.success(isEdit ? 'Category updated successfully' : 'Category created successfully', {
				id: toastId
			});
			invalidateAll();
		} else {
			const errMsg =
				'error' in response ? response.error : response.data?.message || 'Unknown error';
			console.error('[Categories] Failed to save category:', errMsg, response);
			toast.error(`Failed to save category: ${errMsg}`, { id: toastId });
		}
	}

	async function deleteCategory() {
		if (!selectedCategoryForDelete) return;

		const toastId = toast.loading('Deleting category...');
		const response = await invokeService<any, any>('/post-inventory-item-category', {
			body: {
				process_type: 2,
				item_category_id: selectedCategoryForDelete.item_category_id,
				description: selectedCategoryForDelete.item_category_description,
				user_id: data.user.member?.member_id ?? 1
			},
			token: data.user.access_token
		});

		deleteOpen = false;

		if ('data' in response && response.data.success) {
			toast.success('Category deleted successfully', { id: toastId });
			invalidateAll();
		} else {
			const errMsg =
				'error' in response ? response.error : response.data?.message || 'Unknown error';
			console.error('[Categories] Failed to delete category:', errMsg, response);
			toast.error(`Failed to delete category: ${errMsg}`, { id: toastId });
		}
	}
</script>

<svelte:head>
	<title>Categories - Serenity Inventory</title>
</svelte:head>

<div class="space-y-6">
	<!-- Page Header -->
	<div class="flex items-center justify-between">
		<div>
			<h2 class="font-playfair text-2xl font-bold text-primary">Item Categories</h2>
			<p class="text-sm text-muted-foreground">
				Classify inventory items into logic-driven groups.
			</p>
		</div>
		<Button
			onclick={openAdd}
			class="flex items-center gap-2 bg-primary text-white hover:bg-primary/95"
		>
			<Icon icon="mdi:plus" width="20" />
			Add Category
		</Button>
	</div>

	<!-- Search Filter -->
	<div class="rounded-xl border bg-card p-4 shadow-sm">
		<div class="relative w-full sm:max-w-md">
			<Icon icon="mdi:magnify" width="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
			<Input
				type="text"
				placeholder="Search category name..."
				bind:value={searchQuery}
				autocomplete="off"
				class="pl-9 h-10"
			/>
		</div>
	</div>

	<!-- Table list -->
	<TableControls
		{columns}
		bind:visibleColumns
		bind:limit
		bind:page
		total={filteredCategories.length}
	>
		<Table.Root>
			<Table.Header>
				<Table.Row class="border-b-2 border-primary/10 bg-primary/5 hover:bg-primary/5">
					{#if visibleColumns.name !== false}
						<Table.Head class="text-xs font-bold tracking-wider text-foreground/60 uppercase"
							>Category Name</Table.Head
						>
					{/if}
					{#if visibleColumns.status !== false}
						<Table.Head class="text-xs font-bold tracking-wider text-foreground/60 uppercase"
							>Charge Account</Table.Head
						>
					{/if}
					<Table.Head
						class="w-[60px] text-center text-xs font-bold tracking-wider text-foreground/60 uppercase"
					></Table.Head>
				</Table.Row>
			</Table.Header>
			<Table.Body>
				{#if paginatedCategories.length === 0}
					<Table.Row>
						<Table.Cell
							colspan={columns.filter((c) => visibleColumns[c.key] !== false).length + 1}
							class="h-40 text-center"
						>
							<div class="flex flex-col items-center gap-2 text-muted-foreground">
								<Icon icon="mdi:tag-off-outline" width="36" class="opacity-30" />
								<span class="text-sm">No categories found.</span>
							</div>
						</Table.Cell>
					</Table.Row>
				{:else}
					{#each paginatedCategories as category, i (category.item_category_id)}
						<Table.Row
							class="transition-colors hover:bg-primary/5 {i % 2 === 1 ? 'bg-muted/20' : ''}"
						>
							{#if visibleColumns.name !== false}
								<Table.Cell class="font-semibold text-foreground"
									>{category.item_category_description}</Table.Cell
								>
							{/if}
							{#if visibleColumns.status !== false}
								<Table.Cell class="font-semibold text-foreground"
									>{category.glsl_item_elab}</Table.Cell
								>
							{/if}
							<Table.Cell class="text-center">
								<DropdownMenu.Root>
									<DropdownMenu.Trigger class="rounded-lg p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground focus:outline-none">
										<Icon icon="mdi:dots-vertical" width="17" />
									</DropdownMenu.Trigger>
									<DropdownMenu.Content class="bg-card rounded-xl shadow-xl border border-border p-1.5 min-w-44 z-50 mt-1" align="end">
										<DropdownMenu.Item onclick={() => openEdit(category)} class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors text-teal-650 dark:text-teal-455 font-medium">
											<Icon icon="mdi:pencil-outline" width="16" />
											Edit
										</DropdownMenu.Item>
										<DropdownMenu.Separator class="my-1 border-t border-border" />
										<DropdownMenu.Item onclick={() => openDelete(category)} class="flex items-center gap-2 hover:bg-rose-500/10 text-rose-500 px-3 py-2 rounded-lg cursor-pointer text-sm font-semibold transition-colors">
											<Icon icon="mdi:delete-outline" width="16" />
											Delete
										</DropdownMenu.Item>
									</DropdownMenu.Content>
								</DropdownMenu.Root>
							</Table.Cell>
						</Table.Row>
					{/each}
				{/if}
			</Table.Body>
		</Table.Root>
	</TableControls>

	<!-- Form Dialog -->
	<Dialog.Root bind:open={formOpen}>
		<Dialog.Content
			onInteractOutside={(e) => e.preventDefault()}
			onEscapeKeydown={(e) => e.preventDefault()}
			class="overflow-hidden rounded-2xl border-0 bg-card p-0 shadow-2xl sm:max-w-[460px]"
		>
			<div class="border-b bg-primary/5 px-6 py-4">
				<div class="flex items-center gap-3">
					<div class="flex h-9 w-9 items-center justify-center rounded-xl bg-primary/10">
						<Icon
							icon={selectedCategory ? 'mdi:pencil' : 'mdi:plus'}
							width="18"
							class="text-primary"
						/>
					</div>
					<Dialog.Title class="text-lg font-bold text-foreground">
						{selectedCategory ? 'Edit Category' : 'New Category'}
					</Dialog.Title>
				</div>
			</div>
			<form onsubmit={submitForm} class="space-y-4 px-6 py-5">
				<div class="flex flex-col gap-1.5">
					<Label
						for="cat_name"
						class="text-xs font-bold tracking-wider text-muted-foreground uppercase"
						>Category Name *</Label
					>
					<Input
						type="text"
						id="cat_name"
						placeholder="e.g. Tires, Oils"
						bind:value={categoryDescription}
						autocomplete="off"
						class="h-10"
						required
					/>
				</div>
				<div class="flex min-w-0 flex-col gap-1.5 overflow-hidden">
					<Label class="text-xs font-bold tracking-wider text-muted-foreground uppercase"
						>GL/SL Account</Label
					>
					<SearchCombobox
						options={data.glslAccounts.map((a: any) => ({ value: a.glsl_id, label: a.account }))}
						bind:value={glslId}
						placeholder="Select GL/SL account..."
						searchPlaceholder="Search accounts..."
					/>
				</div>
				<div class="flex justify-end gap-2 border-t pt-4">
					<Button
						type="button"
						variant="outline"
						onclick={() => (formOpen = false)}
						class="h-9 px-5">Cancel</Button
					>
					<Button type="submit" class="h-9 bg-primary px-5 text-white hover:bg-primary/90"
						>Save Category</Button
					>
				</div>
			</form>
		</Dialog.Content>
	</Dialog.Root>

	<!-- Delete Confirmation -->
	<Dialog.Root bind:open={deleteOpen}>
		<Dialog.Content
			class="overflow-hidden rounded-2xl border-0 bg-card p-0 shadow-2xl sm:max-w-[400px]"
		>
			{#if selectedCategoryForDelete}
				<div class="border-b border-rose-100 bg-rose-50 px-6 py-4">
					<div class="flex items-center gap-3">
						<div class="flex h-9 w-9 items-center justify-center rounded-xl bg-rose-100">
							<Icon icon="mdi:delete-alert-outline" width="18" class="text-rose-600" />
						</div>
						<Dialog.Title class="text-lg font-bold text-rose-700">Delete Category</Dialog.Title>
					</div>
				</div>
				<div class="px-6 py-5">
					<p class="text-sm text-muted-foreground">
						Are you sure you want to delete <span class="font-bold text-foreground"
							>"{selectedCategoryForDelete.item_category_description}"</span
						>? Items in this category will be detached.
					</p>
					<div class="mt-5 flex justify-end gap-2 border-t pt-5">
						<Button variant="outline" onclick={() => (deleteOpen = false)} class="h-9 px-5"
							>Cancel</Button
						>
						<Button
							onclick={deleteCategory}
							class="h-9 bg-rose-600 px-5 text-white hover:bg-rose-700">Delete</Button
						>
					</div>
				</div>
			{/if}
		</Dialog.Content>
	</Dialog.Root>
</div>
