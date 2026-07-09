<script lang="ts">
    import type { User } from '$lib/types';
    import * as Card from "$lib/components/ui/card/index.js";
    import Icon from "@iconify/svelte";
    import Button from "./button/button.svelte";

    let { user }: { user: User } = $props();

    const fullName = $derived(
      user?.member
        ? `${user.member.first_name} ${user.member.last_name}`
        : "Guest"
    );

    const greeting = $derived(`Hi ${fullName}`);

    const memberStats = [
        {
            id: "Class",
            icon: "mdi:yoga",
            number: "12",
            title: "Classes Enrolled In",
            url: "/dashboard/classes"
        },
    ];

    const adminStats = [
        {
            id: "Users",
            icon: "mdi:account",
            number: "12",
            title: "Total Users",
            url: "/dashboard/user-management"
        },
        {
            id: "Class",
            icon: "mdi:yoga",
            number: "12",
            title: "Total Classes",
            url: "/dashboard/class-management"
        }
    ];

    const cardStats = $derived(user?.role?.role_name === "admin" ? adminStats : memberStats);
</script>

<main>
    <h1>{greeting}</h1>
    <div class="flex gap-4">
        {#each cardStats as stat(stat.id)}
        <Card.Root>
            <Card.Content>
                <Card.Title>
                    <Icon icon={stat.icon} width="24" height="24" class="text-secondary mb-6"></Icon>
                    <p class="text-3xl">{stat.number}</p>
                </Card.Title>
                <Card.Description>
                    <p class="text-primary font-bold mb-4 text-base">{stat.title}</p>
                </Card.Description>
                <Card.Footer>
                    <Button variant="link" class="text-secondary group hover:text-primary">View more
                        <Icon icon="mdi:arrow-right" class="text-secondary group-hover:text-primary"></Icon>
                    </Button>
                </Card.Footer>
            </Card.Content>
        </Card.Root>
        {/each}
    </div>
    {#if user?.role?.role_name === "admin"} 
        <h1>Admin Content</h1>
    {:else}
        <h1>User Content</h1>
    {/if}
</main>
