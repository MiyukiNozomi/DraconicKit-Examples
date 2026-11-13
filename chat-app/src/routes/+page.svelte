<script>
  import { slide } from "svelte/transition";

  let isBusy = $state(false);

  let errorMessage = $state();

  let username = $state("");
  let password = $state("");
  let repeatPassword = $state("");

  let isCreatingAccount = $state(false);

  async function submit() {
    errorMessage = undefined;

    isBusy = true;
    try {
      const res = isCreatingAccount
        ? await fetch("/api/register", {
            method: "post",
            headers: { "content-type": "application/json" },
            body: JSON.stringify({ username, password, repeatPassword }),
          })
        : await fetch("/api/login", {
            method: "post",
            headers: { "content-type": "application/json" },
            body: JSON.stringify({ username, password }),
          });
      if (res.status != 200) {
        var txt = await res.text();
        throw txt.length > 0 ? txt : "Got a non-200 response! " + res.status;
      }
      const data = await res.json();

      if (data.ok) {
        window.location.href = "/chat";
      } else {
        throw "Did not get an OK from the server!";
      }
    } catch (e) {
      errorMessage = JSON.stringify(e);
    }
    isBusy = false;
  }
</script>

<svelte:head>
  <title>Skylliope - Draconic Chat Application!</title>
</svelte:head>

<div class="main">
  <img class="logo" src="/skylliope.png" alt="" />

  <div class="loginbox">
    {#if errorMessage}
      <p class="error" transition:slide>{errorMessage}</p>
    {/if}

    <input type="text" bind:value={username} placeholder="Skylliope Name" />
    <input type="password" bind:value={password} placeholder="Password" />

    {#if isCreatingAccount}
      <input
        transition:slide
        type="password"
        bind:value={repeatPassword}
        placeholder="Repeat Password"
      />
    {/if}

    <button disabled={isBusy} onclick={submit} class="submit"
      >{isCreatingAccount ? "Create Account" : "Sign In"}</button
    >
  </div>

  <button class="alt" onclick={() => (isCreatingAccount = !isCreatingAccount)}
    >{isCreatingAccount
      ? "Already have an Account?"
      : "Create an Account"}</button
  >
</div>

<style>
  * {
    box-sizing: border-box;
  }

  .main {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
    max-width: 480px;
    min-height: 100vh;
    min-height: 100dvh;
    margin: 0 auto;
    border-left: 1px solid #00000033;
    border-right: 1px solid #00000033;
    font-family: Arial, Helvetica, sans-serif;
  }

  .logo {
    display: block;
    width: min(320px, 100%);
    height: auto;
    object-fit: contain;
    padding: 1rem 0;
  }

  .loginbox {
    display: flex;
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
    width: 100%;
    max-width: 360px;
    margin-top: 1.5rem;
  }

  input {
    width: 100%;
    min-width: 0;
    border: 1px solid #dedede;
    padding: 1rem 1.2rem;
    font-size: 1.1rem;
    color: #000000ee;
    border-radius: 6px;
    outline: none;
    transition: border-color 0.2s;
  }

  input:focus {
    border-color: #219ae7;
  }

  .loginbox button {
    width: 100%;
    padding: 1rem;
    border: none;
    border-radius: 6px;
    background-color: #219ae7;
    color: white;
    font-size: 1.2rem;
    font-weight: 600;
    cursor: pointer;
    transition:
      background-color 0.2s,
      opacity 0.2s;
  }

  .loginbox button:hover {
    background-color: rgb(20, 86, 128);
  }

  .loginbox button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  button.alt {
    margin-top: auto;
    flex-shrink: 0;
    width: 100%;
    padding: 1.5rem;
    border: none;
    border-top: 1px solid #dedede;
    background-color: white;
    color: #219ae7;
    font-size: 1.2rem;
    font-weight: 400;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  button.alt:hover {
    background-color: #f5f5f5;
  }

  .error {
    width: 100%;
    margin: 0;
    padding: 1rem;
    border: 1px solid red;
    border-radius: 6px;
    background: rgba(255, 53, 53, 0.15);
    color: #740101;
    overflow-wrap: anywhere;
  }

  @media (max-width: 360px) {
    input {
      font-size: 1rem;
      padding: 0.9rem;
    }

    button.alt {
      font-size: 1.1rem;
    }
  }
</style>
