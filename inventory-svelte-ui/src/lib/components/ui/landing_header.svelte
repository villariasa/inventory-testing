<script lang="ts">
    import {Button} from "$lib/components/ui/button/index.js";
    import { goto } from '$app/navigation';
    import Icon from "@iconify/svelte";
    import * as NavigationMenu from "$lib/components/ui/navigation-menu/index.js";
    import logo from "$lib/assets/landing/serenity_logo.png";

    let mobileMenuOpen = false;

    function toggleMenu(){
      mobileMenuOpen = !mobileMenuOpen;
    }

    async function goToSignUp(){
        goto('/register');
    }
</script>


<header class="top-0 sticky px-6 py-4 box-border bg-transparent!">
  <a href="#main-content" class="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-white focus:text-teal-dark focus:rounded">
    Skip to content
  </a>
  <div class="flex flex-row items-center justify-between">

    <!-- --Logo-- -->
    <img src={logo} alt="Serenity Yoga Studio Logo" class="w-30 h-auto " />

    <!-- --Links-- -->
    <nav class="hidden md:flex items-center">
        <NavigationMenu.Root>
          <NavigationMenu.List class="flex gap-6 text-teal-dark">
            <NavigationMenu.Item>
              <NavigationMenu.Link class="hover:text-secondary transition" href="#home">
                Home
              </NavigationMenu.Link>
            </NavigationMenu.Item>

            <NavigationMenu.Item>
              <NavigationMenu.Link class="hover:text-secondary transition" href="#services">
                Services
              </NavigationMenu.Link>
            </NavigationMenu.Item>
      
            <NavigationMenu.Item>
              <NavigationMenu.Link class="hover:text-secondary transition" href="#team">
                Our Team
              </NavigationMenu.Link>
            </NavigationMenu.Item>
      
            <NavigationMenu.Item>
              <NavigationMenu.Link class="hover:text-secondary transition" href="#testimonials">
                Testimonials
              </NavigationMenu.Link>
            </NavigationMenu.Item>
      
            <NavigationMenu.Item>
              <NavigationMenu.Link class="hover:text-secondary transition" href="#contacts">
                Contacts
              </NavigationMenu.Link>
            </NavigationMenu.Item>
      
          </NavigationMenu.List>
        </NavigationMenu.Root>
    </nav>
    
    <!-- --Auth Buttons-- -->
    <div class="hidden md:flex gap-4">
        <Button variant="default" onclick={() => goto('/login')}>Login</Button>
        <Button variant="secondary" onclick={goToSignUp}>Sign-Up</Button>
    </div>

      <!-- --Mobile Hamburger-- -->
     <Button variant="ghost" size="icon-lg" class="md:hidden" onclick={toggleMenu} aria-expanded={mobileMenuOpen} aria-controls="mobile-menu" aria-label="toggle menu">
      {#if mobileMenuOpen}
        <Icon icon="mdi:close" class="text-teal-dark"></Icon>
      {:else}
        <Icon icon="mdi:menu" class="text-teal-dark"></Icon>
      {/if}
     </Button>
  </div>

    {#if mobileMenuOpen}
      <div class="flex flex-col gap-3 mt-5 md:hidden justify-center items-center p-4 bg-white/50 rounded-lg text-teal-dark" id="mobile-menu" role="navigation" aria-label="Mobile Navigation">
        
        <a href="#home" class="hover:text-secondary hover:underline transition">
          Home
        </a>

        <a href="#services" class="hover:text-secondary hover:underline transition">
          Services
        </a>

        <a href="#team" class="hover:text-secondary hover:underline transition">
          Our Team
        </a>

        <a href="#testimonials" class="hover:text-secondary hover:underline transition">
          Testimonials
        </a>

        <a href="#contacts" class="hover:text-secondary hover:underline transition">
          Contacts
        </a>

        <div class="flex gap-4 justify-center mt-4">
          <Button variant="default" onclick={() => goto('/login')}>
            Login
          </Button>
          <Button variant="secondary" onclick={goToSignUp}>
            Sign-Up
          </Button>
        </div>
      </div>
    {/if}
</header>
