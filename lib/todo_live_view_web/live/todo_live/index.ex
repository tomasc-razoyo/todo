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
    IO.inspect(params)

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

  def handle_event("todo_attempt_complete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, updated_todo} = Todos.update_todo(todo, %{completed: !todo.completed})

    socket =
      if updated_todo.completed == true do
        socket |> put_flash(:info, "Todo has been completed")
      else
        socket |> put_flash(:error, "Todo has been set to active")
      end

    socket =
      socket
      |> push_event("todo_is_complete", %{
        id: updated_todo.id,
        completed: updated_todo.completed
      })

    {:noreply, socket}
  end
end
