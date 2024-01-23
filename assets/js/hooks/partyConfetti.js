import party from "party-js";

const PartyConfetti = {
    id() { return this.el.dataset.id },
    mounted() {
        this.el.addEventListener("click", e => {
            this.pushEvent('todo_attempt_complete', { id: this.id() });
        });

        this.handleEvent('todo_is_complete', ({ id, completed }) => {
            if (completed && this.id() == id) {
                party.confetti(this.el);
            }
        });
    }
}

export default PartyConfetti;