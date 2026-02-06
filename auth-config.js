// auth-config.js - Centralized Security & Auth
const SUPABASE_URL = 'https://qesgfxwgbggjyvngftee.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_MJQrnWCSsg0naLA9hxkPzQ__diYSGYi';

// 1. FIX: Use sessionStorage so closing the tab logs the user out
const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    auth: {
        persistSession: true,
        storage: window.sessionStorage 
    }
});

let idleTimer;

// 2. FIX: Unified Inactivity Logic
function resetIdleTimer() {
    clearTimeout(idleTimer);
    idleTimer = setTimeout(autoLogout, 900000); // 15 minutes
}

async function autoLogout() { 
    console.log("Inactivity logout triggered.");
    await signOut(); 
}

async function signOut() { 
    await supabaseClient.auth.signOut(); 
    // Redirect back to the root of the current app
    window.location.href = window.location.origin + window.location.pathname; 
}

// Global Activity Listeners
window.onmousemove = resetIdleTimer;
window.onmousedown = resetIdleTimer; 
window.ontouchstart = resetIdleTimer; 
window.onclick = resetIdleTimer;     
window.onkeypress = resetIdleTimer;
