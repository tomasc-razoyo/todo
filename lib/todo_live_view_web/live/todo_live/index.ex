defmodule TodoLiveViewWeb.TodoLive.Index do
  use TodoLiveViewWeb, :live_view

  alias TodoLiveView.Todos
  alias TodoLiveView.Todos.Todo

  @impl true
  def mount(_params, _session, socket) do
    # {:ok, stream(socket, :todos, Todos.list_todos())}
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    # {:noreply, apply_action(socket, socket.assigns.live_action, params)}
    apply_filter(socket, params)
  end

  defp apply_filter(socket, params) do
    list_todos = Todos.list_todos()
    IO.inspect(socket.assigns)

    case params["filter_by"] do
      "completed" ->
        completed_todos =
          Enum.filter(list_todos, &(&1.completed == true))

        {:noreply,
         socket
         |> stream(:todos, completed_todos, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      "active" ->
        active_todos =
          Enum.filter(list_todos, &(&1.completed == false))

        {:noreply,
         socket
         |> stream(:todos, active_todos, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      _ ->
        {:noreply,
         socket
         |> stream(:todos, list_todos, reset: true)
         |> apply_action(socket.assigns.live_action, params)}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Todo")
    |> assign(:todo, Todos.get_todo!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:todo, %Todo{})
  end

  @impl true
  def handle_info({TodoLiveViewWeb.TodoLive.FormComponent, {:saved, todo}}, socket) do
    {:noreply, stream_insert(socket, :todos, todo)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, _} = Todos.delete_todo(todo)

    {:noreply, stream_delete(socket, :todos, todo)}
  end

  def handle_event("toggle_todo", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, _} = Todos.update_todo(todo, %{completed: !todo.completed})

    {:noreply,
     socket
     |> put_flash(:info, "Todo has been completed")
     |> push_patch(to: ~p"/todos")}
  end
end
