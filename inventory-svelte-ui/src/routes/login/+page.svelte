<script lang="ts">
  import { Button } from '$lib/components/ui/button/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import * as Card from '$lib/components/ui/card/index.js';
  import Icon from '@iconify/svelte';
  import { goto } from '$app/navigation';
  import { toast } from 'svelte-sonner';
  import { userStore } from '$lib/store/user';

  let email = $state('');
  let password = $state('');
  let loading = $state(false);

  let emailError = $state(false);
  let passwordError = $state(false);

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  async function performLogin(terminate_existing_session?: boolean): Promise<void> {
    loading = true;

    try {
      const response = await fetch('/service/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, terminate_existing_session })
      });

      const data = await response.json();

      if (response.status === 409 && data.session_conflict) {
        toast.warning('Active Session Detected', {
          description: 'You have an active session on another device.',
          duration: Infinity,
          action: {
            label: 'Terminate & Continue',
            onClick: async () => {
              toast.dismiss();
              await performLogin(true);
            }
          },
          cancel: {
            label: 'Cancel',
            onClick: () => {
              toast.dismiss();
            }
          }
        });
        return;
      }

      if (!response.ok || !data.success) {
        if (data.error_code === 'INVALID_PASSWORD') {
          passwordError = true;
          toast.error('Invalid password. Please try again.');
        } else {
          toast.error(data.message || data.error || 'Invalid credentials');
        }
        return;
      }

      const backendRole = typeof data.user.role === 'string'
        ? data.user.role
        : data.user.role.role_name;

      userStore.set({
        member: {
          ...data.user.member
        },
        role: {
          role_id: data.user.role?.role_id ?? 1,
          role_name: backendRole
        },
        loggedIn: true,
        access_token: data.user.access_token,
        session_id: data.user.session_id
      });

      sessionStorage.setItem('access_token', data.user.access_token);
      sessionStorage.setItem('session_id', data.user.session_id);

      toast.success('Welcome back!');
      setTimeout(() => { goto('/select-app'); }, 1000);

    } catch (error) {
      console.error(error);
      toast.error('Connection error. Please check your backend endpoints.');
    } finally {
      loading = false;
    }
  }

  async function handleLogin(e: Event): Promise<void> {
    e.preventDefault();
    emailError = false;
    passwordError = false;

    if (!email || !password) {
      if (!email) emailError = true;
      if (!password) passwordError = true;
      toast.error('Please enter email and password');
      return;
    }

    if (!emailRegex.test(email)) {
      emailError = true;
      toast.error('Please enter a valid email address');
      return;
    }

    await performLogin();
  }
</script>

<svelte:head>
  <title>Login - Serenity Inventory</title>
</svelte:head>

<main class="min-h-screen w-full flex items-center justify-center bg-gradient-to-tr from-teal-dark via-[#1d5952] to-green-muted p-4 sm:p-6">
  <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-mint-pale/10 via-transparent to-transparent pointer-events-none"></div>

  <Card.Root class="w-full max-w-md bg-white/95 backdrop-blur-md shadow-2xl border border-white/10 rounded-2xl overflow-hidden py-10 px-6 sm:px-8 relative animate-fade-in duration-300">
    <Card.Header class="pb-6">
      <div class="flex flex-col items-center gap-2 mb-2">
        <div class="h-12 w-12 rounded-xl bg-primary flex items-center justify-center text-white shadow-lg shadow-primary/20">
          <Icon icon="mdi:warehouse" width="28" height="28" />
        </div>
        <span class="text-xs uppercase font-extrabold tracking-widest text-primary/60">Serenity Platform</span>
      </div>
      <Card.Title class="text-center text-3xl font-extrabold font-playfair text-primary">Inventory Hub</Card.Title>
      <Card.Description class="text-center text-sm text-muted-foreground mt-1">Sign in to manage items, units, and reports.</Card.Description>
    </Card.Header>
    <Card.Content>
      <form onsubmit={handleLogin} class="space-y-5">
        <div class="flex flex-col gap-2">
          <Label for="email" class={emailError ? 'text-rose-500' : 'text-slate-700 dark:text-slate-300 font-semibold text-sm'}>Email Address</Label>
          <div class="relative">
            <span class="absolute inset-y-0 left-0 pl-3 flex items-center text-muted-foreground">
              <Icon icon="mdi:email" width="20" />
            </span>
            <Input
              id="email"
              type="email"
              placeholder="name@company.com"
              bind:value={email}
              class="pl-10 h-11 border-border bg-slate-50/50 dark:bg-muted/50 focus-visible:ring-primary {emailError ? 'border-rose-500 text-rose-500' : ''}"
              required
            />
          </div>
        </div>

        <div class="flex flex-col gap-2">
          <Label for="password" class={passwordError ? 'text-rose-500' : 'text-slate-700 dark:text-slate-300 font-semibold text-sm'}>Password</Label>
          <div class="relative">
            <span class="absolute inset-y-0 left-0 pl-3 flex items-center text-muted-foreground">
              <Icon icon="mdi:lock" width="20" />
            </span>
            <Input
              id="password"
              type="password"
              placeholder="••••••••"
              bind:value={password}
              class="pl-10 h-11 border-border bg-slate-50/50 dark:bg-muted/50 focus-visible:ring-primary {passwordError ? 'border-rose-500 text-rose-500' : ''}"
              required
            />
          </div>
        </div>

        <Button
          type="submit"
          class="w-full h-11 bg-primary hover:bg-primary/95 text-white font-bold rounded-lg shadow-lg shadow-primary/10 transition-all duration-200 flex items-center justify-center gap-2 mt-4"
          disabled={loading}
        >
          {#if loading}
            <Icon icon="mdi:loading" class="animate-spin" width="20" />
            Signing In...
          {:else}
            <Icon icon="mdi:login" width="20" />
            Sign In
          {/if}
        </Button>
      </form>
    </Card.Content>
  </Card.Root>
</main>
