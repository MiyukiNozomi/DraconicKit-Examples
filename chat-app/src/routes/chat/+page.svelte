<script>
  import { onMount } from "svelte";

  let data = $props();

  let errorMessage = $state();
  let onlineCount = $state(0);

  let messages = $state([]);

  let messageCtn = $state("");

  let ws;

  onMount(() => {
    messages.push({
      author: "Skylliope",
      content: "Connecting! please wait!",
      time: new Date(),
    });

    ws = new WebSocket("/api/ws");

    ws.onerror = (e) => {
      messages.push({
        author: "Skylliope",
        content: "Connection failed! check inspector",
        time: new Date(),
      });
    };

    ws.onmessage = (m) => {
      console.log(m.data);
      const d = JSON.parse(m.data);

      onlineCount = d.onlineCount;
      messages.push(d);
    };
  });

  async function send() {
    if (messageCtn.trim().length != 0);

    if (ws)
      ws.send(
        JSON.stringify({
          content: messageCtn,
        }),
      );
    messageCtn = "";
  }
</script>

<svelte:head>
  <title>Skylliope - Draconic Chat Application!</title>
</svelte:head>

<div class="main">
  <div class="header">
    <a href="/" class="back">&lt;</a>
    <div class="middle">
      <h1>Skylliope Chatroom</h1>
      <p>{onlineCount} online</p>
    </div>
  </div>
  <div class="content">
    {#if errorMessage}
      <p class="error" transition:slide>{errorMessage}</p>
    {/if}

    {#each messages as msg}
      {@const time = new Date(msg.time)}
      <div
        class="message {msg.author == data.accountInfo.username ? 'ours' : ''}"
      >
        <div class="arrow"></div>
        <p class="time">
          {time.getHours()}:{time.getMinutes().toString().padStart(2, "0")}
        </p>
        <h1>{msg.author}</h1>
        <p>{msg.content}</p>
      </div>
    {/each}
  </div>
  <form
    class="inputbox"
    action="#"
    onsubmit={(e) => {
      e.preventDefault();
      send();
    }}
  >
    <input
      bind:value={messageCtn}
      type="text"
      placeholder="Type in a message"
    />
    <button>Send</button>
  </form>
</div>

<style>
  * {
    box-sizing: border-box;
  }

  .main {
    display: flex;
    flex-direction: column;
    width: 100%;
    max-width: 480px;
    min-height: 100vh;
    margin: 0 auto;
    border-left: 1px solid #00000033;
    border-right: 1px solid #00000033;
    font-family: Arial, Helvetica, sans-serif;
  }

  .header {
    position: relative;
    display: grid;
    grid-template-columns: 40px 1fr 40px;
    align-items: center;
    width: 100%;
    padding: 0.75rem;
    background-color: #219ae7;
  }

  .header .middle {
    grid-column: 2;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.2rem;
    color: white;
    text-align: center;
  }

  h1,
  p {
    margin: 0;
  }

  .middle h1 {
    font-weight: 700;
    font-size: 1.1rem;
  }

  .middle p {
    font-size: 0.8rem;
    font-weight: 300;
  }

  .header .back {
    grid-column: 1;
    grid-row: 1;
    color: white;
    text-decoration: none;
    font-size: 1.8rem;
    font-weight: 700;
    line-height: 1;
  }

  .content {
    display: flex;
    flex-direction: column;
    padding: 0.65rem;
    min-height: 0;
    flex-grow: 1;
    gap: 1.2rem;
  }

  .inputbox {
    background-color: #f3f5f5;
    padding: 0.35rem;
    display: flex;
    gap: 0.5rem;
    font-size: 1rem;
  }

  .inputbox input {
    outline: none;
    border: none;
    padding: 0.6rem 0.5rem;
    flex-grow: 1;
    font-size: inherit;
    border-radius: 6px;
  }

  .inputbox button {
    background-color: #939498;
    color: white;
    border: none;
    border-radius: 6px;
    outline: none;
    font-size: inherit;
    font-weight: bolder;
    padding: 0.6rem 0.5rem;
  }
  .message .arrow {
    position: absolute;
    background: linear-gradient(35deg, #e0e0e0 50%, transparent 51%);
    width: 1.2rem;
    height: 0.6rem;
    left: 1.6rem;
    top: 0;
    transform: translateY(-90%);
  }
  .message {
    display: flex;
    flex-direction: column;
    position: relative;
    background-color: #e0e0e0;
    border-radius: 8px;
    gap: 0.2rem;
    padding: 0.6rem 0.8rem;
    margin-top: 0.5rem;
  }

  .message.ours {
    background-color: #e6f7fe;
  }
  .message.ours .arrow {
    position: absolute;
    background: linear-gradient(215deg, #e6f7fe 50%, transparent 51%);
    width: 1.2rem;
    height: 0.6rem;
    right: 1.6rem;
    top: 100%;
    left: unset;
    transform: translateY(-10%);
  }

  .message h1 {
    color: #219ae7;
    font-size: 0.9rem;
    margin-top: -0.2rem;
  }

  .message p.time {
    position: absolute;
    right: 0.8rem;
    top: 0.4rem;
    font-size: 0.8rem;
    color: #00000088;
    margin: 0;
  }

  .error {
    background: rgba(255, 53, 53, 0.281);
    border: 1px solid red;
    width: 100%;
    padding: 1.2rem;
    color: #740101;
  }
</style>
