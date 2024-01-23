import party from "party-js";

const PartyConfetti = {
    id() { return this.el.dataset.id },
    mounted() {
        this.el.addEventListener("click", e => {
            this.pushEvent('todo_attempt_complete', { id: this.id() });
            this.handleEvent('todo_is_complete', ({ id, completed }) => {
                console.log(id);
                if (completed)
                    party.confetti(this.el);
            });
        });
    }
}

export default PartyConfetti;