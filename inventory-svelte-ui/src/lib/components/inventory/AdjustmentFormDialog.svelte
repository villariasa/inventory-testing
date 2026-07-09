<script lang="ts">
  import type { AdjustmentTemplate, InventoryUnit, User } from '$lib/types';
  import { invokeService } from '$lib/service/invokeService';
  import { untrack } from 'svelte';
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import { Textarea } from '$lib/components/ui/textarea/index.js';
  import SearchCombobox from '$lib/components/ui/SearchCombobox.svelte';
  import ItemSelect from '$lib/components/inventory/ItemSelect.svelte';
  import { activeUnit, DEFAULT_UNIT } from '$lib/store/unit';
  import { DEFAULT_USER_ID } from '$lib/store/user';

  let {
    open = $bindable(false),
    templates = [],
    units = [],
    user = null,
    onsubmit = () => {}
  } = $props<{
    open: boolean;
    templates: AdjustmentTemplate[];
    units: InventoryUnit[];
    user: User | null;
    onsubmit: (data: any) => void;
  }>();

  // Form state
  let template_id = $state<number | null>(null);
  let source_unit_id = $state<number | null>(null);
  let destination_unit_id = $state<number | null>(null);
  
  let item_id = $state(0);
  let quantity = $state(1);
  let unit_cost = $state(0);
  let remarks = $state('');

  // Comma auto-formatting for unit_cost
  let costInputStr = $state('');

  function formatInputWithCommas(val: string): string {
    let clean = val.replace(/,/g, '');
    clean = clean.replace(/[^\d.]/g, '');
    
    const dotIndex = clean.indexOf('.');
    if (dotIndex !== -1) {
      let before = clean.substring(0, dotIndex);
      let after = clean.substring(dotIndex + 1).replace(/\./g, '');
      
      if (before) {
        const num = parseFloat(before);
        if (!isNaN(num)) {
          before = num.toLocaleString('en-US');
        }
      }
      return before + '.' + after;
    } else {
      if (!clean) return '';
      const num = parseFloat(clean);
      if (isNaN(num)) return '';
      return num.toLocaleString('en-US');
    }
  }

  function handleCostInput(e: Event) {
    const input = e.currentTarget as HTMLInputElement;
    const selectionStart = input.selectionStart;
    const origLen = input.value.length;
    
    const formatted = formatInputWithCommas(input.value);
    costInputStr = formatted;
    
    const numeric = parseFloat(formatted.replace(/,/g, ''));
    unit_cost = isNaN(numeric) ? 0 : numeric;
    
    setTimeout(() => {
      const newLen = formatted.length;
      if (selectionStart !== null) {
        input.setSelectionRange(selectionStart + (newLen - origLen), selectionStart + (newLen - origLen));
      }
    }, 0);
  }

  // User default unit state - default to DEFAULT_UNIT
  let userUnit = $state<{ unit_id: number; description: string; head_office?: number } | null>(DEFAULT_UNIT);
  console.log(userUnit)

  // Sync with global activeUnit store manually to avoid compile-time store auto-subscription loops
  let currentActiveUnit = $state<any>(null);
  $effect(() => {
    const unsubscribe = activeUnit.subscribe(val => {
      currentActiveUnit = val;
    });
    return unsubscribe;
  });

  // Item search states
  let searchedItems = $state<any[]>([]);
  let searchingItems = $state(false);
  let selectedItem = $state<any | null>(null);
  let itemSearchQuery = $state('');

  // Derived options for dropdowns
  let templateOptions = $derived(
    templates.map((t: any) => ({ value: t.template_id, label: t.description }))
  );
  let unitOptions = $derived(
    units.map((u: any) => ({ value: u.unit_id, label: u.description }))
  );
  
  // Format the fetched items for the SearchCombobox
  let itemOptions = $derived(
    searchedItems.map(item => ({
      value: item.item_id,
      label: `${item.item_description || item.model_description} (Cost: ₱${item.unit_cost !== undefined ? item.unit_cost : item.wtd_ave_cost})`
    }))
  );

  // Determine Source/Dest Visibility & Rules
  let selectedTemplate = $derived(templates.find((t: any) => t.template_id === template_id));

  let isHeadOffice = $derived(
    userUnit?.head_office === 1 ||
    userUnit?.description?.toLowerCase().includes('main') || 
    userUnit?.description?.toLowerCase().includes('head') || 
    userUnit?.unit_id === 1
  );

  let showSource = $derived(
    selectedTemplate 
      ? (selectedTemplate.require_destination_and_source === 1 || 
         selectedTemplate.require_destination_and_source === 3 ||
         (selectedTemplate.require_destination_and_source === 0 && selectedTemplate.add_to_quantity === 0)) 
      : false
  );
  
  let showDestination = $derived(
    selectedTemplate 
      ? (selectedTemplate.require_destination_and_source === 2 || 
         selectedTemplate.require_destination_and_source === 3 ||
         (selectedTemplate.require_destination_and_source === 0 && selectedTemplate.add_to_quantity === 1)) 
      : false
  );
  
  let isSourceEditable = $derived(
    selectedTemplate 
      ? (isHeadOffice || (selectedTemplate.add_to_quantity === 1 && selectedTemplate.require_destination_and_source === 3)) 
      : false
  );

  let isDestinationEditable = $derived(
    selectedTemplate
      ? (isHeadOffice || (selectedTemplate.add_to_quantity === 0 && selectedTemplate.require_destination_and_source === 3))
      : false
  );

  // Determined above in order of declaration dependency

  // Determine current active unit to fetch items for
  let currentUnitId = $derived(
    (showSource ? source_unit_id : null) ?? (showDestination ? destination_unit_id : null) ?? userUnit?.unit_id ?? 1
  );

  async function fetchUserUnit() {
    const userId = user?.member?.member_id ?? DEFAULT_USER_ID;
    console.log(userId)
    try {
      const response = await invokeService<any, any>('/get-user-designated-unit', {
        body: { user_id: userId },
        token: user?.access_token
      });
      if ('data' in response && response.data.success) {
        const dataList = response.data?.data?.json_data || [];
        if (dataList.length > 0) {
          userUnit = {
            unit_id: dataList[0].unit_id ?? 1,
            description: dataList[0].unit ?? dataList[0].description ?? 'Main Office',
            head_office: dataList[0].head_office ?? 0
          };
        } else {
          userUnit = { unit_id: 1, description: 'Main Office', head_office: 0 };
        }
      } else {
        userUnit = { unit_id: 1, description: 'Main Office', head_office: 0 };
      }
    } catch (err) {
      console.error('Failed to fetch user unit:', err);
      userUnit = { unit_id: 1, description: 'Main Office', head_office: 0 };
    }
    applyTemplateRules();
  }

  function applyTemplateRules() {
    if (template_id !== null && userUnit) {
      const template = templates.find((t: any) => t.template_id === template_id);
      if (template) {
        let newSourceId: number | null = null;
        let newDestId: number | null = null;
        
        const addToQty = template.add_to_quantity;
        const reqBoth = template.require_destination_and_source;
        
        const localShowSource = reqBoth === 1 || reqBoth === 3 || (reqBoth === 0 && addToQty === 0);
        const localShowDest = reqBoth === 2 || reqBoth === 3 || (reqBoth === 0 && addToQty === 1);
        const localIsSourceEditable = isHeadOffice || (addToQty === 1 && reqBoth === 3);
        const localIsDestEditable = isHeadOffice || (addToQty === 0 && reqBoth === 3);

        if (localShowSource) {
          newSourceId = localIsSourceEditable ? source_unit_id : userUnit.unit_id;
        } else {
          newSourceId = null;
        }

        if (localShowDest) {
          newDestId = localIsDestEditable ? destination_unit_id : userUnit.unit_id;
        } else {
          newDestId = null;
        }

        if (source_unit_id !== newSourceId) {
          source_unit_id = newSourceId;
        }
        if (destination_unit_id !== newDestId) {
          destination_unit_id = newDestId;
        }

        // Reset items only if values are different
        if (selectedItem !== null) selectedItem = null;
        if (item_id !== 0) item_id = 0;
        if (quantity !== 1) quantity = 1;
        if (unit_cost !== 0) { unit_cost = 0; costInputStr = ''; }
      }
    }
  }

  async function fetchItems(unitId: number, query: string = '') {
    searchingItems = true;
    const response = await invokeService<any, any[]>('/get-inventory-unit-item', {
      body: {
        bol_getone: 0,
        unit_id: 3,
        item_category_id: 0, // 0 means search all categories
        unit_item_id: 0,
        item_description: query.trim()
      },
      token: user?.access_token
    });
    console.log({
        bol_getone: 0,
        unit_id: 3,
        item_category_id: 0, // 0 means search all categories
        unit_item_id: 0,
        item_description: query.trim()
      })
    searchingItems = false;
    if ('data' in response && response.data.success) {
      searchedItems = response.data?.data?.json_data || [];
    } else {
      searchedItems = [];
    }
  }

  // --- Effects ---

  // Handle template selection rules
  $effect(() => {
    if (template_id !== null) {
      untrack(() => {
        applyTemplateRules();
      });
    }
  });

  // Auto-fetch items when active unit or search query changes (debounced by 300ms)
  $effect(() => {
    if (open && currentUnitId) {
      const query = itemSearchQuery;
      const unit = currentUnitId;
      const delay = setTimeout(() => {
        fetchItems(unit, query);
      }, 300);
      return () => clearTimeout(delay);
    }
  });

  // Auto-populate item details when item selected from Combobox
  $effect(() => {
    const currentItemId = item_id;
    const currentItems = searchedItems;

    untrack(() => {
      if (currentItemId && currentItemId !== 0) {
        const found = currentItems.find(i => i.item_id === currentItemId);
        if (found && selectedItem?.item_id !== currentItemId) {
          selectedItem = found;
          const rawCost = found.unit_cost !== undefined ? found.unit_cost : (found.wtd_ave_cost || 0);
          unit_cost = typeof rawCost === 'string' ? parseFloat(rawCost.replace(/,/g, '')) : (rawCost || 0);
          costInputStr = formatInputWithCommas(String(unit_cost));
          quantity = found.quantity_cap || 1;
        }
      } else {
        if (selectedItem !== null) selectedItem = null;
        costInputStr = '';
      }
    });
  });

  // Sync / Reset on open
  $effect(() => {
    if (open) {
      untrack(() => {
        template_id = templates[0]?.template_id ?? null;
        source_unit_id = null;
        destination_unit_id = null;
        item_id = 0;
        quantity = 1;
        unit_cost = 0;
        costInputStr = '';
        remarks = '';
        selectedItem = null;
        itemSearchQuery = '';
        searchedItems = [];
        fetchUserUnit();
      });
    }
  });

  function handleQuantityBlur() {
    const cap = selectedItem?.quantity_cap || 1;
    if (quantity % cap !== 0) {
      quantity = Math.ceil(quantity / cap) * cap;
    }
  }

  function triggerSubmit(e: Event) {
    e.preventDefault();
    if (item_id === 0) return;

    onsubmit({
      template_id: template_id ?? 0,
      source_unit_id: showSource ? source_unit_id : null,
      destination_unit_id: showDestination ? destination_unit_id : null,
      item_id,
      quantity,
      unit_cost,
      remarks,
      user_id: user?.member?.member_id ?? DEFAULT_USER_ID
    });
  }
</script>

<Dialog.Root bind:open>
  <Dialog.Content
    onInteractOutside={(e) => e.preventDefault()}
    onEscapeKeydown={(e) => e.preventDefault()}
    class="sm:max-w-[550px] bg-card border rounded-lg shadow-xl p-6"
  >
    <Dialog.Header>
      <Dialog.Title class="text-xl font-bold font-playfair text-primary">Create Stock Adjustment</Dialog.Title>
      <Dialog.Description class="text-sm text-muted-foreground">
        Select a template and record stock addition, subtraction, or unit transfer.
      </Dialog.Description>
    </Dialog.Header>

    <form onsubmit={triggerSubmit} class="space-y-4 mt-4">
      <div class="flex flex-col gap-1.5">
        <Label for="template" class="text-sm font-semibold">Adjustment Template *</Label>
        <SearchCombobox
          options={templateOptions}
          bind:value={template_id}
          placeholder="Select Template..."
          searchPlaceholder="Search template..."
        />
      </div>

      <div class="grid grid-cols-2 gap-4">
        {#if showSource}
          <div class="flex flex-col gap-1.5">
            <Label for="source_unit" class="text-sm font-semibold">Source Unit *</Label>
            {#if isSourceEditable}
              <SearchCombobox
                options={unitOptions}
                bind:value={source_unit_id}
                placeholder="Select Source Unit..."
                searchPlaceholder="Search unit..."
              />
            {:else}
              <Input
                type="text"
                readonly
                value={userUnit?.description || 'Loading unit...'}
                class="bg-muted text-muted-foreground font-medium h-10 animate-in fade-in"
              />
            {/if}
          </div>
        {/if}

        {#if showDestination}
          <div class="flex flex-col gap-1.5">
            <Label for="dest_unit" class="text-sm font-semibold">Destination Unit *</Label>
            {#if isDestinationEditable}
              <SearchCombobox
                options={unitOptions}
                bind:value={destination_unit_id}
                placeholder="Select Destination Unit..."
                searchPlaceholder="Search unit..."
              />
            {:else}
              <Input
                type="text"
                readonly
                value={userUnit?.description || 'Loading unit...'}
                class="bg-muted text-muted-foreground font-medium h-10 animate-in fade-in"
              />
            {/if}
          </div>
        {/if}
      </div>

      <div class="flex flex-col gap-1.5">
        <Label for="item_search" class="text-sm font-semibold">Select Item *</Label>
        <ItemSelect
          options={itemOptions}
          bind:value={item_id}
          bind:searchValue={itemSearchQuery}
          placeholder={searchingItems ? "Loading items..." : "Select an item..."}
          searchPlaceholder="Search items..."
          disabled={searchingItems}
          token={user?.access_token}
        />
      </div>

      <div class="grid grid-cols-2 gap-4">
        <div class="flex flex-col gap-1.5">
          <Label for="qty" class="text-sm font-semibold">Quantity {#if selectedItem?.unit}({selectedItem.unit}){/if} *</Label>
          <Input
            type="number"
            id="qty"
            min="1"
            bind:value={quantity}
            onblur={handleQuantityBlur}
            required
          />
        </div>

        <div class="flex flex-col gap-1.5">
          <Label for="adj_cost" class="text-sm font-semibold">Unit Cost (₱) *</Label>
          <Input
            type="text"
            id="adj_cost"
            placeholder="0.00"
            value={costInputStr}
            oninput={handleCostInput}
            required
          />
        </div>
      </div>

      <div class="flex flex-col gap-1.5">
        <Label for="total_cost" class="text-sm font-semibold text-muted-foreground">Total Cost</Label>
        <Input
          type="text"
          id="total_cost"
          value={"₱" + ((quantity || 0) * (unit_cost || 0)).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
          readonly
          class="bg-muted text-muted-foreground font-semibold text-right h-10"
        />
      </div>

      <div class="flex flex-col gap-1.5">
        <Label for="remarks" class="text-sm font-semibold">Remarks</Label>
        <Textarea
          id="remarks"
          placeholder="Reason for adjustment..."
          bind:value={remarks}
          class="min-h-[80px]" 
        />
      </div>

      <div class="flex justify-end gap-2 pt-4 border-t">
        <Button type="button" variant="outline" onclick={() => open = false}>Cancel</Button>
        <Button
          type="submit"
          variant="default"
          class="bg-primary hover:bg-primary/95 text-white"
          disabled={item_id === 0 || (showSource && !source_unit_id) || (showDestination && !destination_unit_id)}
        >
          Submit Adjustment
        </Button>
      </div>
    </form>
  </Dialog.Content>
</Dialog.Root>