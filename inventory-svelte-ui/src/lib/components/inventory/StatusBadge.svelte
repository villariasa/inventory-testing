<script lang="ts">
  let { status = '' } = $props<{ status?: string }>();

  function getStatusClasses(val: string) {
    const s = val.trim().toUpperCase();
    if (['ACTIVE', 'CONFIRMED', 'DELIVERED', 'APPROVED', 'SUCCESS', '1'].includes(s)) {
      return 'bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-950/30 dark:text-emerald-400 dark:border-emerald-900/30';
    } else if (['PENDING', 'IN-TRANSIT', 'IN TRANSIT'].includes(s)) {
      return 'bg-amber-50 text-amber-700 border-amber-200 dark:bg-amber-950/30 dark:text-amber-400 dark:border-amber-900/30';
    } else if (['INACTIVE', 'CANCELLED', 'REJECTED', '0', 'DELETED', 'SUSPENDED'].includes(s)) {
      return 'bg-rose-50 text-rose-700 border-rose-200 dark:bg-rose-950/30 dark:text-rose-400 dark:border-rose-900/30';
    }
    return 'bg-slate-50 text-slate-700 border-slate-200 dark:bg-muted dark:text-muted-foreground dark:border-border';
  }
</script>

<span class="inline-flex items-center gap-1.5 px-2.5 py-1 text-xs font-semibold uppercase tracking-wider rounded-md border {getStatusClasses(status)}">
  {status === '1' ? 'ACTIVE' : status === '0' ? 'INACTIVE' : status}
</span>
