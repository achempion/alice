# defmodule Alice.FileFinder do
#   import Ratatouille.Constants, only: [key: 1]
#   import Ratatouille.View
#   alias Alice.ToyInterface

#   @behaviour ToyInterface

#   @impl ToyInterface
#   def interactions do
#     %{
#       next: %{
#         title: "Move to the next element",
#         bindings: [
#           %{key: key(:arrow_down)}
#         ]
#       },
#       prev: %{
#         title: "Move to the previous element",
#         bindings: [
#           %{key: key(:arrow_up)}
#         ]
#       },
#       close: %{
#         title: "Close",
#         bindings: [
#           %{ch: ?q}
#         ]
#       },
#       select: %{
#         title: "Select currnt element",
#         bindings: [
#           %{key: key(:enter)}
#         ]
#       }
#     }
#   end

#   @impl ToyInterface
#   def init(args) do
#     %{
#       files: File.ls!(),
#       index: 0,
#       events: 1
#     }
#   end

#   @impl ToyInterface
#   def update(_model, {:event, event}, state) do
#     interaction = 1

#     case interaction do
#       :next ->
#         {:update_state, put_in(state, [:index], next_index(state))}

#       :prev ->
#         {:update_state, put_in(state, [:index], prev_index(state))}

#       :select ->
#         path = Enum.at(state[:files], state[:index])
#         {:open_window, {Alice.Editor, %{path: path}}}

#       :close ->
#         :close

#       _ ->
#         :ok
#     end
#   end

#   @impl ToyInterface
#   def render(_model, state) do
#     viewport(offset_y: 0) do
#       for {file, idx} <- Enum.with_index(state[:files]) do
#         if idx == state[:index] do
#           label(content: file, attributes: [:bold])
#         else
#           label(content: file)
#         end
#       end
#     end
#   end

#   defp next_index(state) do
#     max_value = length(state[:files]) - 1
#     next_value = state[:index] + 1

#     if next_value > max_value do
#       max_value
#     else
#       next_value
#     end
#   end

#   defp prev_index(state) do
#     min_value = 0
#     prev_value = state[:index] - 1

#     if prev_value < min_value do
#       min_value
#     else
#       prev_value
#     end
#   end
# end
