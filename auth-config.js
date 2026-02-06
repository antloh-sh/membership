// auth-config.js
const SUPABASE_URL = 'https://qesgfxwgbggjyvngftee.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_MJQrnWCSsg0naLA9hxkPzQ__diYSGYi';

// 1. FIX: Use sessionStorage to log out when the browser/tab closes
const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    auth: {
        persistSession: true,
        storage: window.sessionStorage 
    }
});

let idleTimer;

// 2. FIX: Consolidated Inactivity Timer
function resetIdleTimer() {
    clearTimeout(idleTimer);
    // 15 Minutes = 900,000ms
    idleTimer = setTimeout(autoLogout, 900000); 
}

async function autoLogout() { 
    console.log("Inactivity logout triggered.");
    await signOut(); 
}

// Global Sign Out
async function signOut() { 
    await supabaseClient.auth.signOut(); 
    window.location.reload(); 
}

// Event Listeners for activity
window.onmousemove = resetIdleTimer;
window.onmousedown = resetIdleTimer; 
window.ontouchstart = resetIdleTimer; 
window.onclick = resetIdleTimer;     
window.onkeypress = resetIdleTimer;
