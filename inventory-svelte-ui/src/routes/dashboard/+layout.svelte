<script lang="ts">
  import DashboardHeader from '$lib/components/ui/dashboard_header.svelte';
  import DashboardSidenav from '$lib/components/ui/dashboard_sidenav.svelte';

  let { data, children } = $props();
</script>

<div class="flex min-h-screen bg-background">
  <!-- Sidebar (renders fixed + a spacer) -->
  <DashboardSidenav user={data.user} />

  <!-- Main content area -->
  <div class="flex flex-col flex-1 min-w-0 overflow-hidden">
    <DashboardHeader user={data.user} />
    <main class="flex-1 px-6 py-6 overflow-auto">
      {@render children()}
    </main>
  </div>
</div>
